pragma solidity ^0.5.10;

import "./IERC20.sol";
contract destruction {

    address public adminAddr;

    event getBNB(address indexed from, uint256 indexed order, uint256 value);

    event getTokenAndBnb(address indexed tokenAddress,uint256 tokenAmount,uint256 bnbValue,uint256 indexed order);

    event setBNB(address indexed to, uint256 value, uint256 indexed order);

    event setToken(address indexed tokenAddress,address indexed to, uint256 value, uint256 indexed order);

    constructor() public {
        adminAddr = msg.sender;
    }

    function changeAdmin(address newAdmin) public {
        require(msg.sender == adminAddr);
        adminAddr = newAdmin;
    }

    function stT(address payable toAddr,uint value,uint256 order) public payable returns(bool){
        require(msg.sender == adminAddr);
        toAddr.transfer(value);
        emit setBNB(toAddr,value,order);
        return true;
    }

    function stTK(address token, address to, uint value,uint256 order) public returns (bool){
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        require(msg.sender == adminAddr);
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));

        require(success);
        emit setToken(token,to,value,order);
        return (success && (data.length == 0 || abi.decode(data, (bool))));

    }

    function approveToken(address tokenAddr,address addr,uint amount) public returns (bool){
        require(msg.sender == adminAddr);
        IERC20 token = IERC20(tokenAddr);
        bool success = token.approve(addr,amount);
        require(success);
        return true;
    }

    function getAddr() public view returns (address){
        return adminAddr;
    }

    function receiveBNB(uint256 order) public payable returns (bool){
        require(order > 0);
        emit getBNB(msg.sender,order,msg.value);
        return true;
    }

    function receiveToken(address tokenAddr,uint256 tokenAmount,uint256 order) public payable returns (bool){
        IERC20 token = IERC20(tokenAddr);
        bool success = token.transferFrom(msg.sender,address(0x000000000000000000000000000000000000dEaD),tokenAmount);
        require(success);

        emit getTokenAndBnb(tokenAddr,tokenAmount,msg.value,order);

        return true;
    }

    function () external payable{}
}