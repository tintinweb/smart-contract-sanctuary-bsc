/**
 *Submitted for verification at BscScan.com on 2023-01-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-09-06
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-27
*/

// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

abstract contract ERC20 {
    function transferFrom(address _from, address _to, uint256 _value) external virtual returns (bool success);
    function transfer(address recipient, uint256 amount) external virtual returns (bool);
    function approve(address spender, uint256 amount) external virtual returns (bool);
}

contract Modifier {
    address internal owner; // Constract creater
    address internal approveAddress;
    bool public running = true;
    uint256 internal constant _NOT_ENTERED = 1;  
    uint256 internal constant _ENTERED = 2;
    uint256 internal _status;

    modifier onlyOwner(){
        require(msg.sender == owner, "Modifier: The caller is not the creator");
        _;
    }

    modifier onlyApprove(){
        require(msg.sender == approveAddress || msg.sender == owner, "Modifier: The caller is not the approveAddress");
        _;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    modifier isRunning {
        require(running, "Modifier: No Running");
        _;
    }

    constructor() {
        owner = msg.sender;
        _status = _NOT_ENTERED;
    }

    function setApproveAddress(address externalAddress) public onlyOwner(){
        approveAddress = externalAddress;
    }

    function startStop() public onlyOwner returns (bool success) {
        if (running) { running = false; } else { running = true; }
        return true;
    }

    /*
     * @dev Get approve address
     */
    function getApproveAddress() internal view returns(address){
        return approveAddress;
    }

    fallback () payable external {}
    receive () payable external {}
}

library SafeMath {
    /* a + b */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    /* a - b */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }
    /* a * b */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    /* a / b */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    /* a / b */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    /* a % b */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    /* a % b */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract StringUtil {
    //==============================string工具函数==============================
    function strConcat(string memory _a, string memory _b) internal pure returns (string memory){
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        string memory ret = new string(_ba.length + _bb.length);
        bytes memory bret = bytes(ret);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) bret[k++] = _ba[i];
        for (uint i = 0; i < _bb.length; i++) bret[k++] = _bb[i];
        return string(ret);
    }

    function toString(address account) internal  pure returns (string memory) {
        return toString(abi.encodePacked(account));
    }

    function toString(uint256 value) internal  pure returns (string memory) {
        return toString(abi.encodePacked(value));
    }

    function toString(bytes32 value) internal pure returns (string memory) {
        return toString(abi.encodePacked(value));
    }

    function toString(bytes memory data) internal pure returns (string memory) {
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(2 + data.length * 2);
        str[0] = "0";
        str[1] = "x";
        for (uint i = 0; i < data.length; i++) {
            str[2 + i * 2] = alphabet[uint(uint8(data[i] >> 4))];
            str[3 + i * 2] = alphabet[uint(uint8(data[i] & 0x0f))];
        }
        return string(str);
    }

    function stringToUint(string memory s) internal pure returns(uint256) {
        bytes memory b = bytes(s);
        uint256 result = 0;
        for(uint i = 0; i < b.length; i++) {
            if(uint8(b[i]) >= 48 && uint8(b[i]) <= 57) {
                result = result * 10 + (uint8(b[i]) - 48);
            }
        }
        return result;
    }


    function stringToBytes32(string memory source) internal pure returns(bytes32 result){
        assembly{
            result := mload(add(source,32))
        }
    }

}

interface IUniswapV2Router02 {

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function factory() external view returns (address);

}

contract EasyCoinRecharge is Modifier, StringUtil {

    using SafeMath for uint256;

    address private financingAddress;
    address private withdrawAddress;
    address private swapReceiveAddress;

    address public secretSigner;

    mapping(uint256 => mapping(address => uint256)) private amountMapping;
    mapping(uint256 => mapping(address => uint256)) private actualAmountMapping;
    mapping(uint256 => mapping(address => uint256)) private deductionAmountMapping;
    mapping(uint256 => mapping(address => uint256)) private defaultAmountMapping;
    
    ERC20 private usdtToken;
    IUniswapV2Router02 public immutable uniswapV2Router;

    constructor() {
        usdtToken = ERC20(0xD4Da02aA780b257D3AB7cD4A9F8E50dDf1B6aFE1);
        secretSigner = 0x4556B6F436c33bc9CDB44E87bca656957df26a94;
        financingAddress = address(this);
        withdrawAddress = 0x4556B6F436c33bc9CDB44E87bca656957df26a94;
        swapReceiveAddress = 0xAE6c148Ce7D5a059c67C468F96F4F03E8Ae4f3DD;

        // IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        uniswapV2Router = _uniswapV2Router;

    }

    function setTokenContract(address _usdtToken) public onlyOwner {
        usdtToken = ERC20(_usdtToken);
    }

    function setSecretSigner(address _address) public onlyOwner {
        secretSigner = _address;
    }

    function setFinancingAddress(address _address) public onlyOwner {
        financingAddress = _address;
    }

    function setWithdrawAddress(address _address) public onlyOwner {
        withdrawAddress = _address;
    }

    function setSwapReceiveAddress(address _address) public onlyOwner {
        swapReceiveAddress = _address;
    }

    function recharge(uint256 inputType, string memory inputTypeToStr, address _address, string memory amountToStr, string memory actualAmountToStr, string memory deductionAmountToStr, string memory defaultAmountToStr, bytes32 _r, bytes32 _s, uint8 _v) external isRunning nonReentrant {

        if(msg.sender != _address) {
            _status = _NOT_ENTERED;
            revert("EasyCoin : caller error");
        }

        string memory senderStr = toString(_address);
        uint256 amountToWei = stringToUint(amountToStr);
        uint256 actualAmountToWei = stringToUint(actualAmountToStr);
        uint256 deductionAmountToWei = stringToUint(deductionAmountToStr);
        uint256 defaultAmountToWei = stringToUint(defaultAmountToStr);

        bytes32 msgHash = keccak256(abi.encodePacked(senderStr, inputTypeToStr, amountToStr, actualAmountToStr, deductionAmountToStr, defaultAmountToStr));
        address signer = verifyMessage(msgHash, _v, _r, _s);
        if(signer != secretSigner) {
            _status = _NOT_ENTERED;
            revert("EasyCoin : signer error");
        }

        amountMapping[block.number][msg.sender] = amountToWei;
        actualAmountMapping[block.number][msg.sender] = actualAmountToWei;
        deductionAmountMapping[block.number][msg.sender] = deductionAmountToWei;
        defaultAmountMapping[block.number][msg.sender] = defaultAmountToWei;

        usdtToken.transferFrom(msg.sender, withdrawAddress, actualAmountToWei);

        if(actualAmountToWei > defaultAmountToWei) {
            usdtToken.transfer(withdrawAddress, actualAmountToWei.sub(defaultAmountToWei));
        }

    }

    function verifyMessage(bytes32 _hashedMessage, uint8 _v, bytes32 _r, bytes32 _s) private pure returns (address) {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHashMessage = keccak256(abi.encodePacked(prefix, _hashedMessage));
        address signer = ecrecover(prefixedHashMessage, _v, _r, _s);
        return signer;
    }

    function getInputAmount(uint _number, address _address) public view returns(uint256 amount, uint256 actualAmount, uint256 deductionAmount, uint256 defaultAmount) {
        amount = amountMapping[_number][_address];
        actualAmount = actualAmountMapping[_number][_address];
        deductionAmount = deductionAmountMapping[_number][_address];
        defaultAmount = defaultAmountMapping[_number][_address];
    }

    function approveToken() public onlyOwner {
        usdtToken.approve(address(uniswapV2Router), 115792089237316195423570985008687907853269984665640564039457584007913129639935);
    }

    function swapToken(uint256 swapAmount, address swapTokenAddress) public onlyApprove {

        address[] memory path = new address[](2);
        path[0] = address(usdtToken);
        path[1] = address(swapTokenAddress);

        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            swapAmount,
            0,
            path,
            swapReceiveAddress,
            block.timestamp
        );

    }

    function tokenOutput(address tokenAddress, address receiveAddress, uint256 amountToWei) public onlyOwner {
        ERC20(tokenAddress).transfer(receiveAddress, amountToWei);
    }

}