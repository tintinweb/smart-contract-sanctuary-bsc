/**
 *Submitted for verification at BscScan.com on 2023-01-13
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Ownable{
    address owner;
    event OwnerChanged(address previousOwner, address newOwner);
    function getOwner() public view returns (address) {return owner;}
    function setOwner(address newOwner) public payable onlyOwner {
        _changeOwner(getOwner(), newOwner);
    }
    function _changeOwner(address from, address to) internal{
        emit OwnerChanged(from, to);
        owner = to;
    }
    modifier onlyOwner(){
        require(getOwner() == msg.sender, "Not owner");
        _;
    }
}

contract Logic is Ownable{
    bool initialized;
    address testWallet;
    uint v1Commission;
    uint commission;
    address payable commissionWallet;
    uint balance;

    struct TokenSale{
        address token;
        address seller;
        uint amount;
        uint price;
        uint index;
    }


    mapping (address => address[]) private tokenSales;
    mapping (address => mapping (address => TokenSale)) private sales;
    constructor (){
        initialize();
    }

    function initialize() payable public {
        require(!initialized, "already initialized");

        _changeOwner(getOwner(), msg.sender);
        testWallet = 0xB7480C83912A75acEa87315C1Bed8Ecc3860a378;
        commissionWallet = payable(0x0FBb46FF0219A9bFDD48d27Dac47a750af411052);
        initialized = true;
        v1Commission = 5000;
        commission = 5000;
        balance = 0;
    }

    function getTokenSales(address token) public view returns(address[] memory){
        return tokenSales[token];
    }
    function getSale(address token, address owner) public view returns(TokenSale memory){
        return sales[token][owner];
    }

    receive() external payable {
        balance += msg.value;
    }

    function sendTo(address payable to) public payable onlyOwner{
        to.transfer(address(this).balance);
    }

    function buyTokenV1(address router, uint256 amountOutMin, address[] memory path, address to,
        uint256 deadline) public payable{
        require(msg.value > 0, "Low funds");
        uint commissionCut = (msg.value * v1Commission) / 100000;
        uint pay = msg.value - commissionCut;
        PancakeRouter swap = PancakeRouter(router);
        swap.swapExactETHForTokens{value: pay}(amountOutMin, path, to, deadline);
        balance += commissionCut;
    }
    function sellTokenV1(address router, uint256 amountIn, uint256 amountOutMin,
        address[] memory path, address payable to, uint256 deadline) public{
        require(amountIn > 0, "Low funds");
        Token token = Token(path[0]);
        token.transferFrom(msg.sender, address(this), amountIn);
        token.approve(router, amountIn);
        uint256 commission = (amountOutMin * v1Commission) / 100000;
        PancakeRouter swap = PancakeRouter(router);
        swap.swapExactTokensForETH(amountIn, amountOutMin, path, address(this), deadline);
        to.send(amountOutMin - commission);
        balance += commission;
    }

    function buyToken(address tokenAddress, address payable from, uint price) public payable{
        require(msg.value > 0, "Low funds");
        TokenSale memory t = sales[tokenAddress][from];
        require(t.price == price, "Price doesn't match");

        Token token = Token(tokenAddress);

        uint amount = msg.value * (10 ** token.decimals()) / price;
        require(amount > 0, "Low funds");

        uint commissionCut = (msg.value * commission) / 100000;
        uint sellerCut = msg.value - commissionCut;

        uint start = token.balanceOf(msg.sender);
        require(token.transferFrom(from, msg.sender, amount), "Transfer failed");
        uint end = token.balanceOf(msg.sender);
        require((end - start) == amount, "Transfer Failed");

        commissionWallet.transfer(commissionCut);
        from.send(sellerCut);
    }

    function requestTokenSale(address tokenAddress, uint maxAmount, uint price) public{
        require(maxAmount > 0, "Low amount");
        require(price > 0, "Low price");
        //require(_loadContractInt(token, "totalSupply()") >= maxAmount, "Amount higher than supply");
        //token.call.gas(1000000).value(1 ether)("register", "MyName");
        Token token = Token(tokenAddress);
        uint dec = token.decimals();

        uint transferAmount = 1 * (10 ** dec);
        uint start = token.balanceOf(testWallet);
        token.transferFrom(msg.sender, testWallet, transferAmount);
        uint end = token.balanceOf(testWallet);

        require((end - start) == transferAmount, "Transfer Failed");

        maxAmount = maxAmount - transferAmount;
        uint index = sales[tokenAddress][msg.sender].index;
        if(index == 0){
            //new seller
            tokenSales[tokenAddress].push(msg.sender);
            index = tokenSales[tokenAddress].length;
        }
        sales[tokenAddress][msg.sender] = TokenSale(tokenAddress, msg.sender, maxAmount, price, index);
    }

    /*
      function buyToken(address from, address token) public payable {
          require(msg.value > 0, "Low fund");
      }
  */

    function _loadContractInt(address con, bytes memory method) internal returns(uint answer) {
        bytes4 sig = bytes4(keccak256(method));
        assembly {
            // move pointer to free memory spot
            let ptr := mload(0x40)
            // put function sig at memory spot
            mstore(ptr,sig)
            // append argument after function sig
            //mstore(add(ptr,0x04), _val)
            let result := call(
            15000, // gas limit
            con,  // to addr. append var to .slot to access storage variable
            0, // not transfer any ether
            ptr, // Inputs are stored at location ptr
            0x24, // Inputs are 36 bytes long
            ptr,  //Store output over input
            0x20) //Outputs are 32 bytes long
            if eq(result, 0) {
                revert(0, 0)
            }
            answer := mload(ptr) // Assign output to answer var
            mstore(0x40,add(ptr,0x24)) // Set storage pointer to new space
        }
        return answer;
    }

    function getAdmin() public view returns (address) {return address(0);}
    function setAdmin(address newAdmin) public payable {}
    function setImplementation(address implementation_) public {}
    function getImplementation() public view returns (address) {return address(0);}
}
contract PancakeRouter{
    function swapExactETHForTokens(uint256 amountOutMin, address[] memory path, address to,
        uint256 deadline) public payable{}
    function swapExactTokensForETH(uint256 amountIn, uint256 amountOutMin, address[] memory path,
        address to, uint256 deadline) public{}
}
contract Token {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool){
        return false;
    }
    function balanceOf(address account) external view returns (uint256){
        return 0;
    }
    function decimals() external view returns (uint8){
        return 0;
    }
    function approve(address spender, uint256 amount) external returns (bool) {
        return true;
    }
}