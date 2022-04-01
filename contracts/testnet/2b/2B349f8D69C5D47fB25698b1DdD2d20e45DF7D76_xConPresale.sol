/**
 *Submitted for verification at BscScan.com on 2022-04-01
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function mint(address to, uint256 amount) external;

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

contract xConPresale is Ownable {
    IERC20 public xCon;
    IERC20 public usdc;

    uint256 public presaleStartTime;
    uint256 public tokenPrice;
    uint256 public maxSupply;
    uint256 public soldTokens;
    uint256 public maxBuyLimit;
    mapping(address => uint256) public userContribution;
    mapping(address => uint256) public userTokenBalance;

    mapping(address => bool) public whitelistedUser;

    constructor(
        address _xConToken,
        address _usdcToken,
        uint256 _price,
        uint256 _maxSupply
    ) {
        xCon = IERC20(_xConToken);
        usdc = IERC20(_usdcToken);
        tokenPrice = _price;
        maxSupply = _maxSupply;
        presaleStartTime = block.timestamp;
    }

    modifier isWhitelisted(address _user) {
        require(whitelistedUser[_user], "User is not whitelisted");
        _;
    }

    function whitelistUser(address[] memory _user, bool _status)
        external
        onlyOwner
    {
        for (uint256 i; i < _user.length; i++) {
            whitelistedUser[_user[i]] = _status;
        }
    }

    function buyXCon(uint256 _amount) external isWhitelisted(msg.sender) {
        require(
            userContribution[msg.sender] + _amount <= maxBuyLimit,
            "Amount exceeds max buy limit"
        );
        require(maxSupply >= soldTokens + _amount, "Max Limit Reached!");
        usdc.transferFrom(msg.sender, owner(), _amount);
        xCon.mint(msg.sender, _amount * tokenPrice);

        soldTokens += _amount * tokenPrice;
        userContribution[msg.sender] += _amount;
        userTokenBalance[msg.sender] += _amount * tokenPrice;
    }

    function setMaxBuyLimit(uint256 _limit) external onlyOwner {
        maxBuyLimit = _limit;
    }

    function setMaxSupply(uint256 _max) external onlyOwner {
        maxSupply = _max;
    }

    function setTokenPrice(uint256 _price) external onlyOwner {
        tokenPrice = _price;
    }
}