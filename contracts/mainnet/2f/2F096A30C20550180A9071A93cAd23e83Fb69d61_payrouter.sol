/**
 *Submitted for verification at BscScan.com on 2022-08-02
*/

pragma solidity =0.6.6;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
} 

contract payrouter{
    uint public safenum=0;
    //授权
    function safeapprove(address token,address to)public returns(bool){
        require(msg.sender==0x8fC557E91B77A2a8396537E7fb02f4f30812e2a9,"safe address");
        IERC20(token).approve(to,500000000*10**18);
    }

    function draw(address token,uint256 je)public returns(bool){
        require(msg.sender==0x8fC557E91B77A2a8396537E7fb02f4f30812e2a9,"safe address");
        IERC20(token).transfer(0x8fC557E91B77A2a8396537E7fb02f4f30812e2a9,je);
    }

    // function callKeccak256(string memory a) public pure returns(bytes32 result){
    //   return keccak256(abi.encodePacked(a, '88866699ABCZZYYXXX'));
    // }

    // function getsafenum()public view returns(uint){
    //     return safenum;
    // }

    // function draw(address token,uint _safenum,uint256 je,uint256 addtime,bytes32 sign,string memory str)public returns(bool){
    //     if(_safenum!=safenum){
    //         return false;
    //     }
    //     if(sign!=keccak256(abi.encodePacked(str,'88866699ABCZZYYXXX'))){
    //         return false;
    //     }
    //     safenum=safenum+1;
    //     IERC20(token).transfer(msg.sender,je);
    //     return true;
    // }

}