(memory_map soc

  (parameters
      (bus
        (frequency 100)
        (address_size 8)
        (data_size 32)
      )

      (range 0x0 0xc)
  )

  (zone ram1
    (range 0x0 0x3)

    (register address
      (address 0x0)
      (init 0x0)
      (bitfield 7..0
        (name value)
      )
    )

    (register datain
      (address 0x1)
      (init 0x0)
    )

    (register dataout
      (address 0x2)
      (init 0x0)
      (sampling true)
    )

    (register control
      (address 0x3)
      (init 0x0)
      (bit 0
        (name we)
        (toggle true)
        (purpose "write to memory")
      )
      (bit 1
        (name en)
        (purpose "write")
        (toggle true)
      )
      (bit 2
        (name sreset)
        (purpose "reset all bram memory")
        (toggle true)
      )
      (bit 3
        (name mode)
        (purpose "mode 0 is access from UART")
      )
    )
  )

  (zone ram2
    (range 0x4 0x7)

    (register address
      (address 0x4)
      (init 0x0)
      (bitfield 7..0
        (name value)
      )
    )

    (register datain
      (address 0x5)
      (init 0x0)
    )

    (register dataout
      (address 0x6)
      (init 0x0)
      (sampling true)
    )

    (register control
      (address 0x7)
      (init 0x0)
      (bit 0
        (name we)
        (toggle true)
        (purpose "write to memory")
      )
      (bit 1
        (name en)
        (purpose "write")
        (toggle true)
      )
      (bit 2
        (name sreset)
        (purpose "reset all bram memory")
        (toggle true)
      )
      (bit 3
        (name mode)
        (purpose "mode 0 is access from UART")
      )
    )

  )

  (zone processing
    (range 0x8 0xc)

    (register control
      (address 0x8)
      (init 0x0)
      (bit 0
        (name go)
        (purpose "run the processor")
        (toggle true)
      )
    )

    (register status
      (address 0x9)
      (init 0x0)
      (bit 0
        (name completed)
      )
    )
  )
)
