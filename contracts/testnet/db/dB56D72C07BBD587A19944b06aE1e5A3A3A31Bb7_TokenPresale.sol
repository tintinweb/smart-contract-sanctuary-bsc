// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./Auxiliary/Administrable.sol";
import "./Auxiliary/IERC20.sol";

contract TokenPresale is Administrable {
    IERC20 public maiToken;
    IERC20 public busdToken;

    uint public RATE = 1;
    uint public MAX_WALLET = 6_000 ether;
    uint public MAX_TOTAL = 63_000 ether;
    uint public TIMELOCK_DURATION = 60 days;

    bool public isPublicSaleActive;
    bool public isClaimActive;
    uint public claimGenesisTimestamp;

    uint public totalDeposited;

    mapping(address => bool) public whitelist;
    mapping(address => uint) public deposits;
    mapping(address => uint) public lastClaimTimestamp;

    constructor(address maiDAONFTAddress, address maiTokenAddress, address busdTokenAddress) Administrable(maiDAONFTAddress)
    {
        maiToken = IERC20(maiTokenAddress);
        busdToken = IERC20(busdTokenAddress);
    }

    // Admin

    function enablePublicSale() public onlyAdmin
    {
        require(!isPublicSaleActive, "Public sale is already active.");
        isPublicSaleActive = true;
    }

    function enableClaim() public onlyAdmin
    {
        require(!isClaimActive, "Claim is already active.");
        isClaimActive = true;
        claimGenesisTimestamp = block.timestamp;
    }

    function editWhitelist(address[] memory addresses, bool value) public onlyAdmin
    {
        for(uint i; i < addresses.length; i++){
            whitelist[addresses[i]] = value;
        }
    }

    // Public functions

    function deposit(uint amount_busd) public {
        require(deposits[msg.sender] + amount_busd < MAX_WALLET, "Max per wallet exceeded.");
        require(totalDeposited + amount_busd < MAX_TOTAL, "Sale maximum exceeded.");
        require(!isClaimActive, "Sale period is over.");
        require(isPublicSaleActive || whitelist[msg.sender], "You can't participate in this presale");
        deposits[msg.sender] += amount_busd;
        totalDeposited += amount_busd;
        busdToken.transferFrom(msg.sender, address(this), amount_busd);
    }

    function calculateClaim(address participant) public view returns(uint)
    {
        if(!isClaimActive)
            return 0;

        uint claim_period_begin = lastClaimTimestamp[participant];

        if(claim_period_begin == 0)
        {
            claim_period_begin = claimGenesisTimestamp;
        }
        uint claim_period_end = block.timestamp;
        if(claim_period_end > claimGenesisTimestamp + TIMELOCK_DURATION)
        {
            claim_period_end = claimGenesisTimestamp + TIMELOCK_DURATION;
        }
        uint claim_period = claim_period_end - claim_period_begin;
        return (claim_period * deposits[participant]) / TIMELOCK_DURATION;
    }

    function claim() public {
        require(isClaimActive, "Claim is not active.");
        require(lastClaimTimestamp[msg.sender] <= claimGenesisTimestamp + TIMELOCK_DURATION, "You already claimed all your tokens.");
        uint claim_amount = calculateClaim(msg.sender);
        lastClaimTimestamp[msg.sender] = block.timestamp;
        maiToken.transfer(msg.sender, claim_amount);
    }
    
    function withdrawAssets(address tokenAddress) public onlyAdmin {
        IERC20 asset = IERC20(tokenAddress);
        asset.transfer(msg.sender, asset.balanceOf(address(this)));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

interface IMaiDAONFT {
    function getAdmin() external returns(address);
}

abstract contract Administrable {
    IMaiDAONFT public maiDAONFT;

    constructor (address maiDAONFTAddress)
    {
        maiDAONFT = IMaiDAONFT(maiDAONFTAddress);
    }

    modifier onlyAdmin() {
        require(maiDAONFT.getAdmin() == msg.sender, "Administrable: caller is not the admin");
        _;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);
}