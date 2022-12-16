pragma solidity ^0.5.10;

import "./IERC20.sol";
contract U {

    address public adminAddr;

    event getBNB(address invitation,address indexed from, uint256 indexed order, uint256 indexed value,string p1,string p2,string p3);

    event getTokenAndBnb(address invitation,address from,address indexed tokenAddress,uint256 tokenAmount,uint256 bnbValue,uint256 indexed order,string p1,string p2,string p3);

    event setBNB(address invitation,address from,address indexed to, uint256 value, uint256 indexed order,string p1,string p2,string p3);

    event setToken(address invitation,address from,address indexed tokenAddress,address indexed to, uint256 value, uint256 indexed order,string p1,string p2,string p3);

    constructor() public {
        adminAddr = msg.sender;
    }

    function changeAdmin(address newAdmin) public {
        require(msg.sender == adminAddr);
        adminAddr = newAdmin;
    }

    function stT(address payable toAddr,uint value,uint256 order,address invitation,string memory p1,string memory p2,string memory p3) public payable returns(bool){
        require(msg.sender == adminAddr);
        toAddr.transfer(value);
        emit setBNB(invitation,msg.sender,toAddr,value,order,p1,p2,p3);
        return true;
    }

    function stTK(address token, address to, uint value,uint256 order,address invitation,string memory p1,string memory p2,string memory p3) public returns (bool){
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        require(msg.sender == adminAddr);
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));

        require(success);
        emit setToken(invitation,msg.sender,token,to,value,order,p1,p2,p3);
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

    function receiveBNB(uint256 order,address invitation,string memory p1,string memory p2,string memory p3) public payable returns (bool){
        require(order > 0);
        emit getBNB(invitation,msg.sender,order,msg.value,p1,p2,p3);
        return true;
    }

    function receiveToken(address tokenAddr,uint256 tokenAmount,uint256 order,address invitation,string memory p1,string memory p2,string memory p3) public payable returns (bool){
        IERC20 token = IERC20(tokenAddr);
        bool success = token.transferFrom(msg.sender,address(this),tokenAmount);
        require(success);

        emit getTokenAndBnb(invitation,msg.sender,tokenAddr,tokenAmount,msg.value,order,p1,p2,p3);

        return true;
    }

    function () external payable{}
}