pragma solidity^0.8;

abstract contract ChainlinkFeed {
    function latestAnswer() virtual external view returns (int256);
}

contract FeedLens {

    struct Prices {
        int256 USDC;
        int256 USDT;
        int256 BUSD;
        int256 SXP;
        int256 XVS;
        int256 BNB;
        int256 BTCB;
        int256 ETH;
        int256 LTC;
        int256 XRP;
        int256 BCH;
        int256 DOT;
        int256 LINK;
        int256 DAI;
        int256 FIL;
        int256 BETH;
        int256 ADA;
        int256 DOGE;
        int256 MATIC;
        int256 CAKE;
        int256 AAVE;
        int256 TUSD;
        int256 TRX;
        int256 UST;
        int256 LUNA;
    }

    function getPrices() external view returns (Prices memory) {
        return Prices({
            USDC: ChainlinkFeed(0x51597f405303C4377E36123cBc172b13269EA163).latestAnswer(),
            USDT: ChainlinkFeed(0xB97Ad0E74fa7d920791E90258A6E2085088b4320).latestAnswer(),
            BUSD: ChainlinkFeed(0xcBb98864Ef56E9042e7d2efef76141f15731B82f).latestAnswer(),
            SXP: ChainlinkFeed(0xE188A9875af525d25334d75F3327863B2b8cd0F1).latestAnswer(),
            XVS: ChainlinkFeed(0xBF63F430A79D4036A5900C19818aFf1fa710f206).latestAnswer(),
            BNB: ChainlinkFeed(0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE).latestAnswer(),
            BTCB: ChainlinkFeed(0x264990fbd0A4796A3E3d8E37C4d5F87a3aCa5Ebf).latestAnswer(),
            ETH: ChainlinkFeed(0x9ef1B8c0E4F7dc8bF5719Ea496883DC6401d5b2e).latestAnswer(),
            LTC: ChainlinkFeed(0x74E72F37A8c415c8f1a98Ed42E78Ff997435791D).latestAnswer(),
            XRP: ChainlinkFeed(0x93A67D414896A280bF8FFB3b389fE3686E014fda).latestAnswer(),
            BCH: ChainlinkFeed(0x43d80f616DAf0b0B42a928EeD32147dC59027D41).latestAnswer(),
            DOT: ChainlinkFeed(0xC333eb0086309a16aa7c8308DfD32c8BBA0a2592).latestAnswer(),
            LINK: ChainlinkFeed(0xca236E327F629f9Fc2c30A4E95775EbF0B89fac8).latestAnswer(),
            DAI: ChainlinkFeed(0x132d3C0B1D2cEa0BC552588063bdBb210FDeecfA).latestAnswer(),
            FIL: ChainlinkFeed(0xE5dbFD9003bFf9dF5feB2f4F445Ca00fb121fb83).latestAnswer(),
            BETH: ChainlinkFeed(0x9ef1B8c0E4F7dc8bF5719Ea496883DC6401d5b2e).latestAnswer(),
            ADA: ChainlinkFeed(0xa767f745331D267c7751297D982b050c93985627).latestAnswer(),
            DOGE: ChainlinkFeed(0x3AB0A0d137D4F946fBB19eecc6e92E64660231C8).latestAnswer(),
            MATIC: ChainlinkFeed(0x7CA57b0cA6367191c94C8914d7Df09A57655905f).latestAnswer(),
            CAKE: ChainlinkFeed(0xB6064eD41d4f67e353768aA239cA86f4F73665a1).latestAnswer(),
            AAVE: ChainlinkFeed(0xA8357BF572460fC40f4B0aCacbB2a6A61c89f475).latestAnswer(),
            TUSD: ChainlinkFeed(0xa3334A9762090E827413A7495AfeCE76F41dFc06).latestAnswer(),
            TRX: ChainlinkFeed(0xF4C5e535756D11994fCBB12Ba8adD0192D9b88be).latestAnswer(),
            UST: ChainlinkFeed(0xcbf8518F8727B8582B22837403cDabc53463D462).latestAnswer(),
            LUNA: ChainlinkFeed(0xD660dB62ac9dfaFDb401f24268eB285120Eb11ED).latestAnswer()
        });
    }
}