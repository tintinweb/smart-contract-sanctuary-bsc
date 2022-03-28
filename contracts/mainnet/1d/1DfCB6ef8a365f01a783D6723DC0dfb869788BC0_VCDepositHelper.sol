/**
 *Submitted for verification at BscScan.com on 2022-03-28
*/

pragma solidity 0.7.5;


library SafeToken {
    
    function safeApprove(address token, address to, uint256 value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "!safeApprove");
    }

    function safeTransfer(address token, address to, uint256 value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "!safeTransfer");
    }

    function safeTransferFrom(address token, address from, address to, uint256 value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "!safeTransferFrom");
    }

    function safeTransferETH(address to, uint256 val) internal {
        (bool success,) = to.call{value : val}(new bytes(0));
        require(success, "!safeTransferETH");
    }
}

interface IWETH {
    function deposit() external payable;
}


interface IDepositor {
    function deposit(uint _amount, uint _maxPrice, address _depositor) external returns (uint);

    function payoutFor(uint _value) external view returns (uint);
}

contract VCDepositHelper  {
    using SafeToken for address;
 

    address public immutable deposit;
    address public Token; 

    constructor (address _deposit, address _Token) {
        deposit = _deposit;
        Token = _Token;
    }

    function depositHelper(
        uint _amount,
        uint _maxPrice,
        address _tokenAddress
    ) external payable{
        uint256 payout = 0;
        Token.safeApprove(address(deposit), _amount);
        if (_tokenAddress == address(0)) {
            uint amount =  msg.value;
            require(amount == _amount, 'Wrong amount');
            IWETH(Token).deposit{value : amount}();
            payout = IDepositor(deposit).deposit(_amount, _maxPrice, msg.sender);
        } else {
            Token.safeTransferFrom(msg.sender, address(this), _amount);
            IDepositor(deposit).deposit(_amount, _maxPrice, msg.sender);
        }
    }

    function depositValue(uint256 _amount) public view returns (uint256 ) {
        return  IDepositor(deposit).payoutFor(_amount);
    }

}