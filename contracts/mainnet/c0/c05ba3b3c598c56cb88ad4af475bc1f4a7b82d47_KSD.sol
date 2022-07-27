/**
 *Submitted for verification at BscScan.com on 2022-07-27
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

contract KSD is IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal;
    uint256 public _tTotalFeeMax;
    uint256 private _rTotal;
    uint256 public _buyFee;
    uint256 public _sellFee;
    uint256 public _tFee;
    string private _name;
    string private _symbol;
    uint256 private _decimals;
    address private _destroyAddress = address(0x000000000000000000000000000000000000dEaD);
    address private _fundAddress = address(0x4a848aAfA9db7B261DE7029FA5114751476c61Ba);
    address private _projectAddress = address(0x0A09a0f8c40CAb7B2aFbAad7137f0Ce0cCf84c77);
    address public uniswapV2Pair;
    mapping(address => bool) public havePush;
    constructor(address tokenOwner) {
        _name = "KingsDAO";
        _symbol = "KSD";
        _decimals = 18;
        _tTotal = 2100000 * 10**_decimals;
        _rTotal = (MAX - (MAX % _tTotal));
        _rOwned[tokenOwner] = _rTotal;
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
    function getbuyFee() public view returns (uint256) {
        return _buyFee;
    }
    function getsellFee() public view returns (uint256) {
        return _sellFee;
    }
    function gettFee() public view returns (uint256) {
        return _tFee;
    }
    function set_buyFee(uint256 buyFee) public onlyOwner {
        require(buyFee <= 1000, "The entered amount cannot exceed 1000!" );
        require(buyFee >= 0, "The entered amount must not be less than 0!" );
         _buyFee = buyFee;
    } 
    function set_sellFee(uint256 sellFee) public onlyOwner {        
        require(sellFee <= 1000, "The entered amount cannot exceed 1000!" );
        require(sellFee >= 0, " The entered amount must not be less than 0!" );
         _sellFee = sellFee;
    } 
    function set_tFee(uint256 tFee) public onlyOwner {        
        require(tFee <= 1000, "The entered amount cannot exceed 1000!" );
        require(tFee >= 0, "The entered amount must not be less than 0!" );
         _tFee = tFee;
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
    function _getValues(uint256 tAmount , uint256 Fee) private pure returns (uint256,  uint256) {
        uint256 tFee = tAmount.mul(Fee).div(1000);
        uint256 tTransferAmount = tAmount.sub(tFee);
        return (tTransferAmount, tFee);
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
    function claimTokens() public onlyOwner {
        payable(_owner).transfer(address(this).balance);
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
        require(amount > 100, "Transfer amount must be greater than zero");
        
        uint256 Fee ;        

        if(from == uniswapV2Pair){
                if( to != _projectAddress && to != _fundAddress  && to != _owner && to != uniswapV2Pair && to != address(this)){                   
                    Fee = getbuyFee();
                }else{
                    Fee = 0;
                }                
				_tokenTransferBuy(from, to, amount, Fee);
	    }else if(to == uniswapV2Pair){
                if(from != _projectAddress && from != _fundAddress  && from != _owner && from != uniswapV2Pair && from != address(this)){ 
                   Fee = getsellFee();
                }else{
                   Fee = 0 ;
                }  
                _tokenTransferBuy(from, to, amount, Fee);
        }else{            
            if(from == _projectAddress || from == _fundAddress || from == _owner || from == address(this) || from == address(0)){ 
                Fee = 0 ;
            }else{
                Fee = gettFee();
            }
                _tokenTransferBuy(from, to, amount, Fee);
        }      
    }
    function _tokenTransferBuy(
        address sender,
        address recipient,
        uint256 tAmount,
        uint256 Fee
    ) private {
        uint256 toallamount = balanceOf(sender);
        if(toallamount == tAmount){
            tAmount = tAmount.sub(100);
        }
        uint256 currentRate = _getRate();
        uint256 rAmount = tAmount.mul(currentRate);
        (uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount , Fee);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        if(tFee > 0){
            _takeTransfer(sender, _projectAddress, tFee, currentRate);
            _takeTransfer(sender, recipient, tTransferAmount, currentRate);
        }else{
            _takeTransfer(sender, recipient, tTransferAmount, currentRate);
        }        
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

    function changeRouter(address router) public onlyOwner {
        uniswapV2Pair = router;
    }
}