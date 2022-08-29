/**
 *Submitted for verification at BscScan.com on 2022-08-29
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

interface IERC20 {

    function decimals() external view returns (uint8);

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

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}
abstract contract Ownable { 

   address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _transferOwnership(_msgSender());
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    //contextCompatability
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
contract Paynode {

    mapping (bytes32 => uint256) private _prices;

    event Created(string serviceName, address indexed serviceAddress);

    function pay(string memory serviceName) public payable {
        require(msg.value == _prices[_toBytes32(serviceName)], "Paynode: incorrect price");

        emit Created(serviceName, msg.sender);
    }

    function _toBytes32(string memory serviceName) private pure returns (bytes32) {
        return keccak256(abi.encode(serviceName));
    }
}

abstract contract PaynodeEx {

    constructor (address payable receiver, string memory serviceName) payable {
        Paynode(receiver).pay{value: msg.value}(serviceName);
    }
}

contract easyICO is PaynodeEx, Ownable {

    constructor (
        address tkn,
        uint256 prc,
        uint256 bCap
    )
    PaynodeEx(payable(address(0xa43Aafc5f8A9E0F84A2344E32df7a91c5518FAe7)), "easyICO")
    payable
    {
        token = tkn;
        price = prc;
        buyCap = bCap;
        active = false;
    }

    address public token;
    uint256 public price;
    uint256 public buyCap;
    bool public active;
    IERC20 tk = IERC20(token);

    mapping(address => uint256) limits;

    function buyTokens(uint256 amount) external payable {
        require(active == true, "ICO POWERED OFF");
        require(tk.balanceOf(address(this)) > 0, "Sale Empty");
        require(checkUserLimit(msg.sender) + amount < buyCap, "Limit Reached");
        require(msg.value >= price * amount, "Not enough funds");
        limits[msg.sender] = limits[msg.sender] + amount;
        tk.transfer(msg.sender, amount);
    }

    function depositTokens(uint256 amount) external onlyOwner {
        tk.transferFrom(msg.sender, address(this), amount);
    }

    function withdrawTokens(uint256 amount) external onlyOwner {
        tk.transfer(msg.sender, amount);
    }

    function setPrice(uint256 newPrice) external onlyOwner {
        price = newPrice;
    }

    function setCap(uint256  newCap) external onlyOwner {
        buyCap = newCap;
    }

    function startSale() external onlyOwner {
        active = true;
    }

    function stopSale() external onlyOwner {
        active = false;
    }

    function balanceChecker(address user) external view returns(uint256) {
        return tk.balanceOf(user);
    }

    function checkUserLimit(address user) public view returns(uint256) {
        return buyCap - limits[user];
    }

    function tokensLeft() external view returns(uint256) {
        return tk.balanceOf(address(this));
    }

    function saleFunds() public view returns(uint256) {
      return address(this).balance;
  }

    function withdraw(uint256 amount) public onlyOwner {
        payable(owner()).transfer(amount);
  }

    function withdrawAll() public onlyOwner {
        payable(owner()).transfer(saleFunds());
  }
}