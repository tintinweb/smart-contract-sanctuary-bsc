/**
 *Submitted for verification at BscScan.com on 2022-08-31
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

contract timedICO is PaynodeEx, Ownable {

    constructor (
        address tkn,
        address stkn,
        uint256 prc,
        uint256 tprc,
        uint256 bCap
    )
    PaynodeEx(payable(address(0xa43Aafc5f8A9E0F84A2344E32df7a91c5518FAe7)), "timedICO")
    payable
    {
        token = tkn;
        paymentToken = stkn;
        priceEth = prc;
        priceToken = tprc;
        buyCap = bCap;
        activeEth = false;
        activeToken = false;
    }

    address public token;
    address public paymentToken;
    uint256 public priceEth;
    uint256 public priceToken;
    uint256 public buyCap;
    uint256 public beginDate;
    uint256 public endDate;
    bool public activeEth;
    bool public activeToken;
    IERC20 tk = IERC20(token);
    IERC20 ptk = IERC20(paymentToken);

    mapping(address => uint256) limits;

    function buyTokensWithEth(uint256 amount) external payable {
        require(activeEth == true, "ICO POWERED OFF");
        require(block.timestamp >= beginDate || block.timestamp <= endDate, "Too Early or Too Late");
        require(tk.balanceOf(address(this)) > 0, "Sale Empty");
        if(msg.sender != owner()){
        require(checkUserLimit(msg.sender) + amount < buyCap, "Limit Reached");
        require(msg.value >= priceEth * amount, "Not enough funds");
        limits[msg.sender] = limits[msg.sender] + amount;
        tk.transfer(msg.sender, amount);
        }
        else{tk.transfer(msg.sender, amount);}
    }

    function buyTokensWithTokens(uint256 amount) external payable {
        require(activeToken == true, "ICO POWERED OFF");
        require(block.timestamp >= beginDate || block.timestamp <= endDate, "Too Early or Too Late");
        require(tk.balanceOf(address(this)) > 0, "Sale Empty");
        if(msg.sender != owner()){
        require(checkUserLimit(msg.sender) + amount < buyCap, "Limit Reached");
        require(ptk.transferFrom(msg.sender,address(this),  amount * priceToken), "Not enough funds");
        limits[msg.sender] = limits[msg.sender] + amount;
        tk.transfer(msg.sender, amount);
        }
        else{tk.transfer(msg.sender, amount);}
    }

    function depositTokens(uint256 amount) external onlyOwner {
        tk.transferFrom(msg.sender, address(this), amount);
    }

    function withdrawTokens(uint256 amount) external onlyOwner {
        tk.transfer(msg.sender, amount);
    }

    function setEthPrice(uint256 newPrice) external onlyOwner {
        priceEth = newPrice;
    }

    function setTokenPrice(uint256 newPrice) external onlyOwner {
        priceToken = newPrice;
    }

    function setCap(uint256  newCap) external onlyOwner {
        buyCap = newCap;
    }

    function startSaleEth() external onlyOwner {
        activeEth = true;
    }

    function stopSaleEth() external onlyOwner {
        activeEth = false;
    }

    function startSaleToken() external onlyOwner {
        activeToken = true;
    }

    function stopSaleToken() external onlyOwner {
        activeToken = false;
    }

    function scheduleSaleDays(uint256 start, uint256 end) external onlyOwner {
        require(start < end, "End must be higher than start");
        if(start == 0){beginDate = block.timestamp;}
        else {
            beginDate = block.timestamp + (60*60*24*start);
            endDate = block.timestamp + (60*60*24*end);
        }
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

    function saleFundsEth() public view returns(uint256) {
      return address(this).balance;
    }

    function saleFundsToken() public view returns(uint256) {
      return ptk.balanceOf(address(this));
    }

    function withdrawEth(uint256 amount) public onlyOwner {
        payable(owner()).transfer(amount);
    }

    function withdrawAllEth() public onlyOwner {
        payable(owner()).transfer(saleFundsEth());
    }

    function withdrawPaymentToken(uint256 amount) public onlyOwner {
        tk.transfer(msg.sender, amount);
    }

    function withdrawAllPaymentTokens() public onlyOwner {
        tk.transfer(msg.sender,saleFundsToken());
    }
}