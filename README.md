STOCKIQ INTEGRATION WITH DYNAMICS NAV 09 R2

    1. Files get dropped into a LOCAL folder of a server machine by StockIQ server agent
    2. Files get pulled and read from folder by CU50037_StockIQImport
    3. Files get parsed by D50088_StockIQImport

    Known bugs:
        - When the dataport processes the File it runs into some Field - Decimal incongruencies (small fix)