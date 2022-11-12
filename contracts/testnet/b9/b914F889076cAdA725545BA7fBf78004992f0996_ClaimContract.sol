/**
 *Submitted for verification at BscScan.com on 2022-11-11
*/

/**


*/

// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Ownable {
    address internal owner;

    constructor(address _owner) {
        owner = _owner;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender) , "!Owner"); _;
    }

    function isOwner(address account) private view returns (bool) {
        return account == owner;
    }

    function renounceOwnership() public onlyOwner {
        owner = address(0);
        emit OwnershipTransferred(address(0));
    }  
    event OwnershipTransferred(address owner);
}

contract ClaimContract is Ownable(msg.sender) {

    IERC20 public token;
    uint8 private constant DECIMALS = 9;
    uint256 private constant DECIMALS_SCALING_FACTOR = 10**DECIMALS;
    uint256 private immutable INITIAL_TOKENS_CLAIMABLE;

    mapping(address => uint256) public claimAmounts;

    event InitializeEvent(address indexed tokenAddress);
    event ClaimEvent(address indexed claimee, uint256 indexed claimAmount);

    constructor() {

        address[3] memory addresses = [
            0xCd5496ef9d7fb6657C9F1a4a1753F645994fbfa9,
            0xB85543E122A0a49735dADd2b98aED5CaBC58F485,
            0x526f016B5F6cE31bB9c5f93AA45A38C4DBC0E148
        ];

        uint16[3] memory amounts = [
            3400,  
            3500,
            3600
        ];
        assert(addresses.length == amounts.length);

        uint256 tokenSum;
        for(uint8 ix = 0;ix < amounts.length; ix++){
            tokenSum += amounts[ix];
            claimAmounts[addresses[ix]] = amounts[ix] * DECIMALS_SCALING_FACTOR;
        }

        INITIAL_TOKENS_CLAIMABLE = tokenSum * DECIMALS_SCALING_FACTOR;
    }

    function getInitialClaimableTokens() external view returns (uint256,uint256) {
        return (INITIAL_TOKENS_CLAIMABLE, INITIAL_TOKENS_CLAIMABLE / DECIMALS_SCALING_FACTOR);
    }

    function initialize(address tokenAddress) external onlyOwner {
        token = IERC20(tokenAddress);

        emit InitializeEvent(tokenAddress);
    }

    function claim() external {
        address claimee = msg.sender;

        uint256 amountToClaim = claimAmounts[claimee];
        require(amountToClaim > 0, "No tokens to claim");

        claimAmounts[claimee] = 0;
        token.transfer(claimee, amountToClaim);

        emit ClaimEvent(claimee, amountToClaim);
    }
}