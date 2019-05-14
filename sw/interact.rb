require 'pp'
require "rubyserial"
require 'colorize'

$serial = Serial.new '/dev/ttyUSB1', 19200,8

def read_reg_ary address
  $serial.write [           0x10].pack("C*")
  $serial.write [           address].pack("C*")
  reg=[]
  for i in 0..3
    byte=nil
    byte=$serial.getbyte until byte
    reg << byte
  end
  reg
end

def read_reg address
  val_ary=read_reg_ary(address)
  byte_array_to_int(val_ary)
end

def write_reg_ary addr,data=[]
  $serial.write [            0x11].pack("C*")
  $serial.write [            addr].pack("C*")
  $serial.write data.pack("CCCC")
end

def write_reg addr,data
  write_reg_ary addr, int_to_byte_array(data,4)
end

def hit_a_key
  puts "> hit a key <"
  key=$stdin.gets.chomp
end

def int_to_byte_array num, bytes
  (bytes - 1).downto(0).collect{|byte| (num >> (byte * 8)) & 0xFF}
end

def byte_array_to_int ary
  res=0
  ary.reverse.each_with_index do |byte,idx|
    res+=byte << idx*8
  end
  res
end

# iram access through registers :
# reg 0x0 is address
# reg 0x1 is datain
# reg 0x2 is dataout
# reg 0x3 is control
#  control 0 is we
#  control 1 is ce
#  control 2 is sreset (UNCONNECTED)
#  control 3 is mode (0 is access from UART)
def write_instr_ram addr=[],data=[]
  write_reg_ary 0x0,addr
  write_reg_ary 0x1,data
  write_reg_ary 0x3,[0,0,0,0b0011]
end

def read_instr_ram addr=[]
  write_reg_ary 0x0,addr
  write_reg_ary 0x3,[0,0,0,0b0010]
  read_reg_ary 0x2
end

# ram data access through registers :
# reg 0x4 is address
# reg 0x5 is datain
# reg 0x6 is dataout
# reg 0x7 is control
#  control 0 is we
#  control 1 is en
#  control 2 is sreset (UNCONNECTED)
#  control 3 is mode (0 is access from UART)
def write_data_ram addr=[],data=[]
  write_reg_ary 0x4,addr # BUG fix : was 0x0
  write_reg_ary 0x5,data
  write_reg_ary 0x7,[0,0,0,0b0011]
end

def read_data_ram addr
  write_reg_ary 0x4,addr
  write_reg_ary 0x7,[0,0,0,0b0010]
  read_reg_ary 0x6
end

def show ram
  ram.each do |addr,bytes|
    addr=addr.to_s.rjust(5)
    data=bytes.collect{|byte| "0x"+byte.to_s(16).rjust(2,'0')}.join(" ")
    puts "#{addr} : #{data}"
  end
end

def format ary
  ary.collect{|byte| byte.to_s(16).rjust(2,'0')}.join
end


def hexa x
  "0x"+x.to_s(16).rjust(8,'0')
end

# puts "testing soc rams".center(95,'=')
# puts " "*68+" status |".rjust(9)+" #data |".rjust(9)+" success"
# for test_id in 0..0
#   puts "test #{test_id}".center(80,' ')
#   result_iram=test_ram(test_id,:iram,400)
#   result_dram=test_ram(test_id,:dram,400)
# end
regs={
  :ram1_addr    => 0x0,
  :ram1_datain  => 0x1,
  :ram1_dataout => 0x2,
  :ram1_control => 0x3,
  :ram2_addr    => 0x3,
  :ram2_datain  => 0x4,
  :ram2_dataout => 0x5,
  :ram2_control => 0x7,
  :proc_control => 0x8,
  :proc_status  => 0x9,
}

# regs.each do |reg,addr|
#   puts "=> testing reg  (0x#{addr.to_s(16)}) #{reg}"
#   write_reg addr,0b111
#   val=read_reg addr
#   puts val.to_s(2)
# end

ram1_file="ram1.hex"
ram2_file="ram2.hex"

puts "=> transfering '#{ram1_file}' to SoC RAM 1"
data_wr=[]
IO.readlines(ram1_file).each do |line|
  addr_i,data=line.split.collect{|hexa| hexa[2..-1].to_i(16)}
  addr=int_to_byte_array(addr_i,4)
  data=int_to_byte_array(data,4)
  data_wr << byte_array_to_int(data)
  write_instr_ram(addr,data)
  # puts "reread..."
  # reread=byte_array_to_int(read_instr_ram([0,0,0,addr_i]))
  # puts "0x"+reread.to_s(16)
end
#exit

puts "=> reading back RAM 1..."
data_rd=[]
nb_errors=0
for addr in 0..data_wr.size-1
  data_rd << byte_array_to_int(read_instr_ram([0,0,0,addr]))
  if (rd=data_rd[addr])!=(wr=data_wr[addr])
      nb_errors+=1
      puts "#{hexa(wr)} #{hexa(rd)} ERROR"
  else
      #puts "#{hexa(wr)} #{hexa(rd)}"
  end
end
if nb_errors==0
  puts "=> NO error detected ! Good !"
else
  puts "=> #{nb_errors} found while reading back CODE ram. Leaving..."
  exit
end

puts "=> transfering '#{ram2_file}' to SoC Data RAM 2"
data_wr=[]
IO.readlines(ram2_file).each do |line|
  addr,data=line.split.collect{|hexa| hexa[2..-1].to_i(16)}
  addr=int_to_byte_array(addr,4)
  data=int_to_byte_array(data,4)
  data_wr << byte_array_to_int(data)
  write_data_ram(addr,data)
end

puts "=> reading back data ram..."
data_rd=[]
nb_errors=0
for addr in 0..data_wr.size-1
  data_rd << byte_array_to_int(read_data_ram([0,0,0,addr]))
  if (rd=data_rd[addr])!=(wr=data_wr[addr])
      puts "#{hexa(wr)} #{hexa(rd)} ERROR"
      nb_errors+=1
  else
      #puts "#{hexa(wr)} #{hexa(rd)}"
  end
end

if nb_errors==0
  puts "=> NO error detected ! Good !"
else
  puts "exiting"
  exit
end

puts "=> giving PROCESSING control over BRAMs (1 & 2)"
write_reg 0x3,0x8 #RAM1
write_reg 0x7,0x8 #RAM2

puts "=> reading processor status"
status=read_reg regs[:proc_status]

puts "0b"+status.to_s(2).rjust(8,'0')

puts "=> starting PROCESSING (go!)"
write_reg regs[:proc_control], 0x00000001

puts "=> reading processor status"
status=read_reg(0x9)
puts "0b"+status.to_s(2).rjust(8,'0')

#puts "=> giving UART control over BRAMs (1 & 2)"
#write_reg 0x3,0x0 #RAM1
#write_reg 0x7,0x0 #RAM2

puts "=> reading back data ram 1..."
ram1=[]
for addr in 0..10
   ram1 << byte_array_to_int(read_instr_ram([0,0,0,addr]))
end
pp ram1

puts "=> reading back data ram 2..."
ram2=[]
for addr in 0..10
  byte_ary = read_data_ram([0,0,0,addr])
  ram2 << byte_array_to_int(byte_ary)
end
pp ram2
