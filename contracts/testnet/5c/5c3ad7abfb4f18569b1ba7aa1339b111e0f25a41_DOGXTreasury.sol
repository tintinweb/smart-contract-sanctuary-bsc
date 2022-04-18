/**
 *Submitted for verification at BscScan.com on 2022-04-18
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-09
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;
    address private _previousOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IPancakeSwapRouter{
		function factory() external pure returns (address);
		function WETH() external pure returns (address);

		function addLiquidity(
				address tokenA,
				address tokenB,
				uint amountADesired,
				uint amountBDesired,
				uint amountAMin,
				uint amountBMin,
				address to,
				uint deadline
		) external returns (uint amountA, uint amountB, uint liquidity);
		function addLiquidityETH(
				address token,
				uint amountTokenDesired,
				uint amountTokenMin,
				uint amountETHMin,
				address to,
				uint deadline
		) external payable returns (uint amountToken, uint amountETH, uint liquidity);
		function removeLiquidity(
				address tokenA,
				address tokenB,
				uint liquidity,
				uint amountAMin,
				uint amountBMin,
				address to,
				uint deadline
		) external returns (uint amountA, uint amountB);
		function removeLiquidityETH(
				address token,
				uint liquidity,
				uint amountTokenMin,
				uint amountETHMin,
				address to,
				uint deadline
		) external returns (uint amountToken, uint amountETH);
		function removeLiquidityWithPermit(
				address tokenA,
				address tokenB,
				uint liquidity,
				uint amountAMin,
				uint amountBMin,
				address to,
				uint deadline,
				bool approveMax, uint8 v, bytes32 r, bytes32 s
		) external returns (uint amountA, uint amountB);
		function removeLiquidityETHWithPermit(
				address token,
				uint liquidity,
				uint amountTokenMin,
				uint amountETHMin,
				address to,
				uint deadline,
				bool approveMax, uint8 v, bytes32 r, bytes32 s
		) external returns (uint amountToken, uint amountETH);
		function swapExactTokensForTokens(
				uint amountIn,
				uint amountOutMin,
				address[] calldata path,
				address to,
				uint deadline
		) external returns (uint[] memory amounts);
		function swapTokensForExactTokens(
				uint amountOut,
				uint amountInMax,
				address[] calldata path,
				address to,
				uint deadline
		) external returns (uint[] memory amounts);
		function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
				external
				payable
				returns (uint[] memory amounts);
		function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
				external
				returns (uint[] memory amounts);
		function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
				external
				returns (uint[] memory amounts);
		function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
				external
				payable
				returns (uint[] memory amounts);

		function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
		function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
		function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
		function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
		function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
		function removeLiquidityETHSupportingFeeOnTransferTokens(
			address token,
			uint liquidity,
			uint amountTokenMin,
			uint amountETHMin,
			address to,
			uint deadline
		) external returns (uint amountETH);
		function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
			address token,
			uint liquidity,
			uint amountTokenMin,
			uint amountETHMin,
			address to,
			uint deadline,
			bool approveMax, uint8 v, bytes32 r, bytes32 s
		) external returns (uint amountETH);
	
		function swapExactTokensForTokensSupportingFeeOnTransferTokens(
			uint amountIn,
			uint amountOutMin,
			address[] calldata path,
			address to,
			uint deadline
		) external;
		function swapExactETHForTokensSupportingFeeOnTransferTokens(
			uint amountOutMin,
			address[] calldata path,
			address to,
			uint deadline
		) external payable;
		function swapExactTokensForETHSupportingFeeOnTransferTokens(
			uint amountIn,
			uint amountOutMin,
			address[] calldata path,
			address to,
			uint deadline
		) external;
}


contract DOGXTreasury is Ownable {
    using SafeMath for uint256;

    struct Marketer {
        uint256 _percent;
        uint256 _balance;
        uint256 _paidETH;
        address _address;
        bool _autoPayETH;
    }

    address[] private _marketers;
    address private _manager;

    mapping(address => Marketer) private _marketerInfos;
    uint256 private _totalPaidETH;
    uint256 private _unRegisteredETH;

    uint256 constant _feeDenominator = 10000;

    constructor(address manager) {
        _manager = manager;
    }

    fallback() external payable {
        if (msg.value > 0) {
            _unRegisteredETH = _unRegisteredETH.add(msg.value);
            _autoPayMarketers(msg.value);
        }
    }

    function addLiquidity(
        address token,
        uint256 tokenAmount,
		address to
    ) payable external onlyOwner {
		IPancakeSwapRouter router = IPancakeSwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); 
		IERC20(token).approve(address(router), type(uint256).max);

        router.addLiquidityETH{value: msg.value}(
                token,
                tokenAmount,
                0,
                0,
                to,
                block.timestamp + 60
            );
    }

    function setMarketer(address marketer, uint256 percent, bool autoPayETH) external onlyOwner {
        require(marketer != address(0x0), "invalid param");

        if (_marketerInfos[marketer]._address == address(0x0)) {
            _marketers.push(marketer);
            _marketerInfos[marketer]._address = marketer;
        }

        _marketerInfos[marketer]._autoPayETH = autoPayETH;
        _marketerInfos[marketer]._percent = percent;
    }

    function setAutoPayETH(address marketer, bool autoPayETH) external onlyOwner {
        require(marketer != address(0x0) && _marketerInfos[marketer]._address != address(0x0), "invalid param");
        _marketerInfos[marketer]._autoPayETH = autoPayETH;
    }

    function getMarketerInfo(address marketer) external view returns (Marketer memory info) {
        require(marketer != address(0x0) && _marketerInfos[marketer]._address != address(0x0), "invalid param");
        info = _marketerInfos[marketer];
    }

    function getMarketerInfo() external view returns (Marketer memory info) {
        require(_marketerInfos[msg.sender]._address != address(0x0), "invalid param");
        info = _marketerInfos[msg.sender];
    }

    function retrieveTokens(address token, uint amount) external {
        require(msg.sender == _manager || msg.sender == owner(), "only manager allowed");

        uint balance = IERC20(token).balanceOf(address(this));

        if(amount > balance){
            amount = balance;
        }

        require(IERC20(token).transfer(msg.sender, amount), "Transfer failed");
    }

    function retrieveTokens(address token, address to, uint amount) external {
        require(msg.sender == _manager || msg.sender == owner(), "only manager allowed");
        require(to != address(0x0), "invalid param");

        uint balance = IERC20(token).balanceOf(address(this));

        if(amount > balance){
            amount = balance;
        }

        require(IERC20(token).transfer(to, amount), "Transfer failed");
    }

    function retrieveBNB(uint amount) external {
        require(_marketerInfos[msg.sender]._percent > 0 && _marketerInfos[msg.sender]._balance > 0, "only marketer allowed");

        if (amount > _marketerInfos[msg.sender]._balance)
            amount = _marketerInfos[msg.sender]._balance;

        _safeTransferETH(msg.sender, amount);
    }

    function retrieveBNB() external {
        require(_marketerInfos[msg.sender]._percent > 0 && _marketerInfos[msg.sender]._balance > 0, "only marketer allowed");
        _safeTransferETH(msg.sender, _marketerInfos[msg.sender]._balance);
    }

    function getTotalPaidETH() external view returns(uint256) {
        require(msg.sender == owner() || msg.sender == _manager, "invalid param");
        return _totalPaidETH;
    }

    function changeNewManager(address manager) external onlyOwner {
        require(manager != address(0x0), "invalid param");
        _manager = manager;
    }

    function whoIsManager() external view returns(address) {
        require(_marketerInfos[msg.sender]._address != address(0x0) || msg.sender == owner(), "only marketer allowed");   
        return _manager;
    }

    function payETHtoMarketers() external onlyOwner {
        _autoPayMarketers(_unRegisteredETH);
    }

    function _autoPayMarketers(uint256 amount) internal {
        for (uint256 i = 0; i < _marketers.length; i++) {
            Marketer storage marketer = _marketerInfos[_marketers[i]];
            uint256 eachAmount = amount.div(_feeDenominator).mul(marketer._percent);
            marketer._balance = marketer._balance.add(eachAmount);
            _unRegisteredETH = _unRegisteredETH.sub(eachAmount);

            if (marketer._autoPayETH) {
                _safeTransferETH(marketer._address, marketer._balance);
            }
        }
    }

    function _safeTransferETH(address to, uint256 value) internal {
        _marketerInfos[to]._balance = _marketerInfos[to]._balance.sub(value);
        _marketerInfos[to]._paidETH = _marketerInfos[to]._paidETH.add(value);
        _totalPaidETH = _totalPaidETH.add(value);

        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TRANSFER_FAILED');
    }
}