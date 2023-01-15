/**
 *Submitted for verification at BscScan.com on 2023-01-14
*/

//SPDX-License-Identifier: NO

pragma solidity 0.8.17;

//--- Context ---//
abstract contract Context {
    constructor() {
    }

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}

//--- Ownable ---//
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

//--- Interface for ERC20 ---//
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

contract AnalytixPrivateSale is Context, Ownable { 

    // Token Whitelisted To Buy
    mapping (IERC20 => bool) private _tokenWhitelisted;

    // Contributions
    mapping(address  => uint256) private BNB_Contribution;
    mapping(address  => uint256) private Token_Contribution;

    // Others Mapping
    mapping(address  => uint256) private TokensPurchased;
    mapping(address  => bool) private oracle;


    // Others
    bool private isLive; // Sale Live
    uint256 private maxBNB = 3 * 10**18; // max contribution
    uint256 private minBNB = 1 * 10**16; // min contribution
    uint256 private checkHardCap = 200; // missing BNB to HardCap;
    uint256 private hardcap = 200; // BNB
    uint256 private rate = 200_000; // USD x Token
    uint256 private bnb_rate = 303; // Price BNB (Updated X time)

    IERC20 private USDT = IERC20(0x55d398326f99059fF775485246999027B3197955);
    IERC20 private USDC = IERC20(0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d);
    IERC20 private BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

    constructor() {
        _tokenWhitelisted[USDT] = true;
        _tokenWhitelisted[USDC] = true;
        _tokenWhitelisted[BUSD] = true;
        isLive = true;
    }

    function buyBNB(uint256 tokens) public payable {
        require(isLive,"Sale is not live");

        tokens = msg.value;
        BNB_Contribution[msg.sender] += tokens;

        require(BNB_Contribution[msg.sender] <= maxBNB,"You are trying to buy too many tokens");

        uint256 purchase = tokens * bnb_rate;

        TokensPurchased[msg.sender] += purchase;
        checkHardCap = checkHardCap - tokens;
        require(checkHardCap == 0 || checkHardCap > 0,"Sale ended");
    }


    function buyTokens(address token, uint256 amount) external {
        IERC20 Token = IERC20(token);
        uint256 purchase = amount / bnb_rate;

        require(_tokenWhitelisted[Token],"Token isn't whitelisted");
        require(isLive,"Sale is not live");
        require(purchase >= minBNB,"Does not meet min contribution criteria");


        BNB_Contribution[msg.sender] += purchase;

        require(BNB_Contribution[msg.sender] >= maxBNB,"Does not meet max contribution criteria");

        TokensPurchased[msg.sender] += purchase;
        checkHardCap = checkHardCap - purchase;
        require(checkHardCap == 0 || checkHardCap > 0,"Sale ended");
    }

    receive() external payable {
    buyBNB(msg.value);
}

    function tokenPurchased(address holder) external view returns (uint256) {
        return TokensPurchased[holder];
    }

    // Claim of tokens another smart contract.
 
}