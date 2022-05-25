/**
 *Submitted for verification at BscScan.com on 2022-05-25
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

contract HoneyPresale is Ownable {
    using SafeMath for uint256;

    struct Holder {
        uint256 _amounts;
        uint256 _tokens;
        bool _claimed;
        address _address;
    }

    address private _manager;

    mapping(address => Holder) private _holdersInfo;
    mapping(address => bool) private _inWhitelist;

    bool    public _enableWhitelist = false;
    uint256 public _tokenPrice;
    uint256 public _tokenSold;
    uint256 public _startTime;
    uint256 public _endTime;
    uint256 public _minBuyAmount;
    uint256 public _maxBuyAmount;
    uint256 public _totalWhitelists;
    uint256 public _totalUsers;
    uint256 public _claimedUsers;
    uint256 public _liquidityPercentage = 80;
    address public _liquidityReceiver = 0xda143Be4Ff739cBF4Af98A82d873B964bb1F6ea8;
    address public tokenPresale = 0x40428f4cF8d0e3aB5e6Cc92aE1080d5e3173464A;
    address public pancakeRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    constructor(address manager) {
        _manager = manager;
    }

    receive() external payable {
    }

    function setWhitelists(address[] calldata whitelists) external {
        require(msg.sender == _manager || msg.sender == owner(), "only manager allowed");
        require(whitelists.length > 0, "invalid param");
        require(_enableWhitelist, "not able");

        for (uint i=0; i<whitelists.length; i++) {
            if (whitelists[i] != address(0x0) && !isContract(whitelists[i])) {
                _inWhitelist[whitelists[i]] = true;
                _totalWhitelists = _totalWhitelists.add(1);
            }
        }
    }

    function enableWhitelist(bool enable) onlyOwner external {
        _enableWhitelist = enable;
    }

    function setPresale(uint256 price, uint256 minBuy, uint256 maxBuy, uint256 start, uint256 end) external {
        require(msg.sender == _manager || msg.sender == owner(), "only manager allowed");
        require(start < end && start > block.timestamp, "invalid time");
        require(price > 0, "invalid price");
        require(minBuy > 0 && minBuy < maxBuy, "invalid BNB amount");

        _tokenPrice = price;
        _startTime = start;
        _endTime = end;
        _minBuyAmount = minBuy;
        _maxBuyAmount = maxBuy;
    }

    function getHolderInfo(address holder) external view returns (Holder memory _holder) {
        require(holder != address(0x0)
                    && _holdersInfo[holder]._address != address(0x0), "invalid param");
        _holder = _holdersInfo[holder];
    }

    function getHolderInfo() external view returns (Holder memory holder) {
        require(msg.sender != address(0x0) 
                    && _holdersInfo[msg.sender]._address != address(0x0), "invalid param");
        holder = _holdersInfo[msg.sender];
    }

    function isInWhitelist() external view returns (bool) {
        return _inWhitelist[msg.sender];
    }

    function isInWhitelist(address someone) external view returns (bool) {
        return _inWhitelist[someone];
    }

    function getPresaleTokenBalance() external view returns (uint256) {
        return IERC20(tokenPresale).balanceOf(address(this));
    }

    function getPresaleBNBBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function buy() external payable returns(uint) {
        if (_enableWhitelist) {
            require(_inWhitelist[msg.sender], "only whitelist allowed");
        }
        require(block.timestamp >= _startTime && block.timestamp < _endTime, "presale not running");
        require(msg.value >= _minBuyAmount 
                && _holdersInfo[msg.sender]._amounts.add(msg.value) <= _maxBuyAmount, "invalid buy amount");

        uint256 balance = IERC20(tokenPresale).balanceOf(address(this));
        require(balance > 0, "no tokens");

        uint256 tokens = msg.value.mul(_tokenPrice).div(10**18);
        require(balance >= tokens, "no enough tokens");

        if (_holdersInfo[msg.sender]._address == address(0x0)) {
            _holdersInfo[msg.sender]._address = msg.sender;
            _totalUsers = _totalUsers.add(1);
        }

        _holdersInfo[msg.sender]._claimed = false;
        _holdersInfo[msg.sender]._amounts = _holdersInfo[msg.sender]._amounts.add(msg.value);
        _holdersInfo[msg.sender]._tokens = _holdersInfo[msg.sender]._tokens.add(tokens);

        _tokenSold = _tokenSold.add(tokens);

        return _holdersInfo[msg.sender]._tokens;
    }

    function claim() external returns(bool) {
        if (_enableWhitelist) {
            require(_inWhitelist[msg.sender], "only whitelist allowed");
        }
        require(block.timestamp > _endTime, "presale not finish");
        require(!_holdersInfo[msg.sender]._claimed && _holdersInfo[msg.sender]._tokens > 0, "no tokens");

        uint tokens = _holdersInfo[msg.sender]._tokens;
        uint balance = IERC20(tokenPresale).balanceOf(address(this));
        if(tokens > balance){
            tokens = balance;
        }

        _holdersInfo[msg.sender]._tokens = 0;
        _holdersInfo[msg.sender]._claimed = true;
        _holdersInfo[msg.sender]._amounts = 0;

        _claimedUsers = _claimedUsers.add(1);

        require(IERC20(tokenPresale).transfer(msg.sender, tokens), "Transfer failed");

        return true;
    }

    function retrieveTokens() external {
        require(msg.sender == _manager || msg.sender == owner(), "only manager allowed");
        require(block.timestamp > _endTime + 2 days, "presale not finish");

        uint balance = IERC20(tokenPresale).balanceOf(address(this));
        require(IERC20(tokenPresale).transfer(msg.sender, balance), "Transfer failed");
    }

    function retrieveTokens(address to) external {
        require(msg.sender == _manager || msg.sender == owner(), "only manager allowed");
        require(to != address(0x0), "invalid param");
        require(block.timestamp > _endTime + 2 days, "presale not finish");

        uint balance = IERC20(tokenPresale).balanceOf(address(this));
        require(IERC20(tokenPresale).transfer(to, balance), "Transfer failed");
    }

    function setLiquidityPercentage(address receiver, uint percentage) external {
         require(msg.sender == _manager || msg.sender == owner(), "only manager allowed");
         require(percentage > 50, "liquidity percentage should be greate than 50%");
          require(receiver != address(0x0), "liquidity receiver should be exist");

         _liquidityPercentage = percentage;
         _liquidityReceiver = receiver;
    }

    function claimBNB() external {
        require(msg.sender == _manager || msg.sender == owner(), "only manager allowed");
        require(block.timestamp > _endTime, "presale not finish");

        IPancakeSwapRouter router = IPancakeSwapRouter(pancakeRouter); 
		IERC20(tokenPresale).approve(address(router), type(uint256).max);

        uint256 balanceBNB = address(this).balance;
        uint256 amountBNB = balanceBNB.mul(_liquidityPercentage).div(100);
        uint256 amountToken = amountBNB.mul(_tokenPrice).div(10**18);
        uint256 balanceToken = IERC20(tokenPresale).balanceOf(address(this));

        require(amountToken <= balanceToken, "liquidity need more tokens");

        router.addLiquidityETH{value:amountBNB}(
                tokenPresale,
                amountToken,
                0,
                0,
                _liquidityReceiver,
                block.timestamp + 60
            );

        _safeTransferETH(msg.sender, address(this).balance);
    }

    function forceWithdraw() external {
        if (_enableWhitelist) {
            require(_inWhitelist[msg.sender], "only whitelist allowed");
        }
        require(block.timestamp < _endTime, "presale ended");
        require(_holdersInfo[msg.sender]._amounts > 0, "no amount");

        uint amount = _holdersInfo[msg.sender]._amounts.mul(90).div(100);
        if(amount > address(this).balance){
            amount = address(this).balance;
        }

        _tokenSold = _tokenSold.sub(_holdersInfo[msg.sender]._tokens);
        _holdersInfo[msg.sender]._amounts = 0;
        _holdersInfo[msg.sender]._tokens = 0;
        _safeTransferETH(msg.sender, amount);
    }

    function changeNewManager(address manager) external onlyOwner {
        require(manager != address(0x0), "invalid param");
        _manager = manager;
    }

    function whoIsManager() external view returns(address) {
        return _manager;
    }

    function _safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TRANSFER_FAILED');
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
}