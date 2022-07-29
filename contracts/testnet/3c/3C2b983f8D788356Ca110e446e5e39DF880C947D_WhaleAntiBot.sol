// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IWhaleswapFactory {
    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);
}

contract WhaleAntiBot {
    address public ownerContract;
    // address public tokenAntiBotAddress;
    // bool public protecing;
    // bool public hasPayFee;
    // address private pairAddress;
    // uint256 public AmountPerTrade;
    // uint256 public AmountAddedPerBlock;
    // uint256 public TimePerTrade;
    // uint256 public BlockNumToDisable;
    // uint256 public BlockNumAtFirst;
    // bool public SetBlockNumAtFirstYet;
    // bool public addedLiqui;
    address public WBNBAddress;

    mapping(bytes32 => bool) public hasConfig;
    mapping(bytes32 => bool) public protecing;
    mapping(bytes32 => address[]) public addressAntibotToken;
    mapping(bytes32 => bool) public registerAntibotToken;
    mapping(bytes32 => bool) public hasPayFee;
    mapping(bytes32 => bool) public addedLiqui;
    mapping(bytes32 => address) public pairAddress;

    mapping(bytes32 => uint256) public AmountPerTrade;
    mapping(bytes32 => uint256) public AmountAddedPerBlock;
    mapping(bytes32 => uint256) public TimePerTrade;

    mapping(bytes32 => bool) public SetBlockNumAtFirstYet;
    mapping(bytes32 => uint256) public BlockNumAtFirst;
    mapping(bytes32 => uint256) public BlockNumToDisable;

    mapping(bytes32 => mapping(address => uint256)) private lastTradeTime;
    mapping(bytes32 => mapping(address => bool)) private inBlackList;
    mapping(bytes32 => mapping(address => bool)) private inWhiteList;

    IWhaleswapFactory public whaleswapFactory;

    constructor() {
        ownerContract = msg.sender;
    }

    function setWBNBAddress(address wBnbAddress_) public {
        require(msg.sender == ownerContract, "Caller is not the owner");
        require(wBnbAddress_ != address(0), "Address can not be Adress(0)");
        WBNBAddress = wBnbAddress_;
    }

    // antibot Token contract register to using antibot, just register once for security
    // function regisImplementAntibot(address owner_contract) public {
    //     bytes32 byte32Address = addressToBytes32(msg.sender, owner_contract);
    //     require(
    //         registerAntibotToken[byte32Address] == false,
    //         "antibot token contract already register"
    //     );
    //     addressAntibotToken[byte32Address] = [msg.sender, owner_contract];
    //     registerAntibotToken[byte32Address] = true;
    // }

    // contract antibot token send info include address contract + owner to set inplement
    // function setImplementTokenContract(
    //     address addressContract,
    //     address addressOwner
    // ) external {
    //     require(
    //         addressContract != address(0),
    //         "cant set from the zero address"
    //     );
    //     require(addressOwner == address(0), "cant set from the zero address");
    //     ownerContract = _owner;
    // }

    // function setTokenAntiBotAddress(address token) external {
    //     require(token != address(0), "cant set from the zero address");
    //     require(
    //         tokenAntiBotAddress == address(0),
    //         "already have token antibot address"
    //     );
    //     tokenAntiBotAddress = token;
    // }

    function checkHasPayFee(address owner_contract) public view returns (bool) {
        bytes32 byte32Address = addressToBytes32(msg.sender, owner_contract);
        return hasPayFee[byte32Address];
    }

    // settingPayFee is call from antibotToken contract
    function settingPayFee(address owner_contract) public returns (bool) {
        bytes32 byte32Address = addressToBytes32(msg.sender, owner_contract);
        require(
            msg.sender == addressAntibotToken[byte32Address][1],
            "Caller is not the owner of antibotToken Contract"
        );
        hasPayFee[byte32Address] = true;
        return true;
    }

    // contract antibot Token need check first. If added liqui and not Listing Block #1
    // => then set BlockNumAtFirst and can enable protecing
    function checkAddedLiquidityAndCheckSetBlockNum(address owner_contract)
        public
        view
        returns (uint8)
    {
        address pair = whaleswapFactory.getPair(WBNBAddress, msg.sender);
        if (pair == address(0)) {
            return 0;
        } else {
            bytes32 byte32Address = addressToBytes32(
                msg.sender,
                owner_contract
            );
            if (SetBlockNumAtFirstYet[byte32Address] == false) {
                return 2;
            }
            return 1;
        }
    }

    function setAddedLiquidityAndSetBlockNum(address owner_contract)
        public
        returns (bool)
    {
        bytes32 byte32Address = addressToBytes32(msg.sender, owner_contract);

        require(
            registerAntibotToken[byte32Address] == true,
            "antibot token contract doesnt register"
        );
        require(
            msg.sender == addressAntibotToken[byte32Address][1],
            "Caller is not the owner of antibotToken Contract"
        );

        address pair = whaleswapFactory.getPair(WBNBAddress, msg.sender);
        addedLiqui[byte32Address] = true;
        pairAddress[byte32Address] = pair;

        // set blocknumber (when checked addliquid. Listing is Block #1)
        BlockNumAtFirst[byte32Address] = block.number;
        SetBlockNumAtFirstYet[byte32Address] = true;

        return addedLiqui[byte32Address];
    }

    function resetBlockNumAtFirst(address tokenAntiBot_Address)
        public
        returns (bool)
    {
        bytes32 byte32Address = addressToBytes32(
            tokenAntiBot_Address,
            msg.sender
        );
        require(
            msg.sender == addressAntibotToken[byte32Address][1],
            "Caller is not the owner of antibotToken Contract"
        );
        SetBlockNumAtFirstYet[byte32Address] = false;
        return true;
    }

    function checkBlockNumber() public view returns (uint256) {
        return block.number;
    }

    // function checkBlockLeftToDisable(address tokenAntiBot_Address)
    //     public
    //     view
    //     returns (uint256)
    // {
    //     bytes32 byte32Address = addressToBytes32(
    //         tokenAntiBot_Address,
    //         msg.sender
    //     );
    //     require(
    //         msg.sender == addressAntibotToken[byte32Address][1],
    //         "Caller is not the owner of antibotToken Contract"
    //     );
    //     if (
    //         BlockNumAtFirst[byte32Address] +
    //             BlockNumToDisable[byte32Address] -
    //             block.number >=
    //         0
    //     ) {
    //         return
    //             BlockNumAtFirst[byte32Address] +
    //             BlockNumToDisable[byte32Address] -
    //             block.number;
    //     } else {
    //         return 0;
    //     }
    // }

    function checkEnableAntiBot(address tokenAntiBot_Address)
        public
        view
        returns (bool)
    {
        bytes32 byte32Address = addressToBytes32(
            tokenAntiBot_Address,
            msg.sender
        );
        return protecing[byte32Address];
    }

    // function enableAntiBot() public returns (bool) {
    //     require(msg.sender == ownerContract, "Caller is not the owner");
    //     protecing = true;
    //     return protecing;
    // }

    // function disableAntiBot() public returns (bool) {
    //     require(msg.sender == ownerContract, "Caller is not the owner");
    //     protecing = false;
    //     return protecing;
    // }

    function checkConfig(address tokenAntiBot_Address)
        public
        view
        returns (
            bool,
            bool,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        bytes32 byte32Address = addressToBytes32(
            tokenAntiBot_Address,
            msg.sender
        );
        require(
            msg.sender == addressAntibotToken[byte32Address][1],
            "Only owner can perform actions"
        );

        uint256 blocksLeftToDisable = BlockNumAtFirst[byte32Address] +
            BlockNumToDisable[byte32Address] -
            block.number;

        return (
            hasConfig[byte32Address],
            addedLiqui[byte32Address],
            AmountPerTrade[byte32Address],
            TimePerTrade[byte32Address],
            blocksLeftToDisable,
            block.number
        );
    }

    function setConfig(
        address tokenAntiBot_Address,
        address whaleswapFactory_,
        uint256 AmountPerTrade_,
        uint256 AmountAddPerBlock_,
        uint256 TimePerTrade_,
        uint256 BlockNumToDisable_
    ) public returns (bool) {
        bytes32 byte32Address = addressToBytes32(
            tokenAntiBot_Address,
            msg.sender
        );

        // when owner antibot contract setConfig at first, need registerAntibotToken to WhaleAntiBot contract
        if (registerAntibotToken[byte32Address] == false) {
            addressAntibotToken[byte32Address] = [
                tokenAntiBot_Address,
                msg.sender
            ];
            registerAntibotToken[byte32Address] = true;
        }

        // check anytime owner setting config
        require(
            msg.sender == addressAntibotToken[byte32Address][1],
            "Caller is not the owner of antibotToken Contract"
        );

        whaleswapFactory = IWhaleswapFactory(whaleswapFactory_);
        AmountPerTrade[byte32Address] = AmountPerTrade_;
        AmountAddedPerBlock[byte32Address] = AmountAddPerBlock_;
        TimePerTrade[byte32Address] = TimePerTrade_;
        BlockNumToDisable[byte32Address] = BlockNumToDisable_;
        return true;
    }

    function addBlackList(address tokenAntiBot_Address, address user)
        public
        returns (bool)
    {
        bytes32 byte32Address = addressToBytes32(
            tokenAntiBot_Address,
            msg.sender
        );
        require(
            msg.sender == addressAntibotToken[byte32Address][1],
            "Only owner can perform actions"
        );
        require(
            inWhiteList[byte32Address][user] != true,
            "Address in WhiteList"
        );
        inBlackList[byte32Address][user] = true;
        return true;
    }

    function addWhiteList(address tokenAntiBot_Address, address user)
        public
        returns (bool)
    {
        bytes32 byte32Address = addressToBytes32(
            tokenAntiBot_Address,
            msg.sender
        );
        require(
            msg.sender == addressAntibotToken[byte32Address][1],
            "Only owner can perform actions"
        );
        require(
            inBlackList[byte32Address][user] != true,
            "Address in BlackList"
        );
        inWhiteList[byte32Address][user] = true;
        return true;
    }

    function removeAddresInWhiteList(address tokenAntiBot_Address, address user)
        public
        returns (bool)
    {
        bytes32 byte32Address = addressToBytes32(
            tokenAntiBot_Address,
            msg.sender
        );
        require(
            msg.sender == addressAntibotToken[byte32Address][1],
            "Only owner can perform actions"
        );
        require(
            inWhiteList[byte32Address][user] == true,
            "Address is not in WhiteList"
        );
        inWhiteList[byte32Address][user] = false;
        return true;
    }

    function removeAddresInBlackList(address tokenAntiBot_Address, address user)
        public
        returns (bool)
    {
        bytes32 byte32Address = addressToBytes32(
            tokenAntiBot_Address,
            msg.sender
        );
        require(
            msg.sender == addressAntibotToken[byte32Address][1],
            "Only owner can perform actions"
        );
        require(
            inBlackList[byte32Address][user] == true,
            "Address is not in BlackList"
        );
        inBlackList[byte32Address][user] = false;
        return true;
    }

    function onPreTransferCheck(
        address from,
        address to,
        uint256 amount,
        address owner_contract
    ) external {
        bytes32 byte32Address = addressToBytes32(msg.sender, owner_contract);
        require(
            msg.sender == addressAntibotToken[byte32Address][1],
            "Caller is not the owner of antibotToken Contract"
        );
        require(
            inBlackList[byte32Address][from] != true,
            "Address in BlackList"
        );

        if (
            addedLiqui[byte32Address] &&
            protecing[byte32Address] &&
            block.number >
            BlockNumAtFirst[byte32Address] + BlockNumToDisable[byte32Address] &&
            inWhiteList[byte32Address][from] != true
        ) {
            if (from == pairAddress[byte32Address]) {
                AmountPerTrade[byte32Address] =
                    AmountPerTrade[byte32Address] +
                    (block.number - BlockNumAtFirst[byte32Address]) *
                    AmountAddedPerBlock[byte32Address];
                require(
                    amount <= AmountPerTrade[byte32Address],
                    "Exceed the amount to trade"
                );
                require(
                    block.timestamp >=
                        lastTradeTime[byte32Address][to] +
                            TimePerTrade[byte32Address],
                    "Trade so fast"
                );

                lastTradeTime[byte32Address][to] = block.timestamp;
            }
        }
        if (
            block.number >
            BlockNumAtFirst[byte32Address] + BlockNumToDisable[byte32Address] &&
            inWhiteList[byte32Address][from] != true
        ) {
            protecing[byte32Address] = false;
        }
    }

    // set 2 address of token antibot contract and owner to bytes32
    function addressToBytes32(address antiContract, address owner)
        private
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(antiContract, owner));
    }
}