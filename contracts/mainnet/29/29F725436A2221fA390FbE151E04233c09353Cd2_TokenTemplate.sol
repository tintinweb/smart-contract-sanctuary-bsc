pragma solidity ^0.5.4;

import './IPancakeRouter.sol';
import './SafeMath.sol';
import './IERC20.sol';
import './IPancakeFactory.sol';


contract ERC20 is IERC20 {
    using SafeMath for uint256;
    mapping (address => uint256) public _balances;
    mapping (address => mapping (address => uint256)) public _allowed;
    uint256 public _totalSupply;

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    function allowance(address owner,address spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }

    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));
        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function increaseAllowance(address spender,uint256 addedValue) public returns (bool) {
        require(spender != address(0));
        _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].add(addedValue));
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender,uint256 subtractedValue) public returns (bool) {
        require(spender != address(0));
        _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].sub(subtractedValue));
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0));
        require(value <= _balances[from]);
        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }
}




contract TokenTemplate is ERC20 {
    string  private _name = "LLTCS";
    string  private _symbol = "LLTCS";
    uint8   private _decimals = 18;
    address public pancakeToken = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public usdtToken = 0x55d398326f99059fF775485246999027B3197955;
    address public zheToken = 0x52a853B9A5873F727056cc981a6e9fbcAA442EA9;
    address public pancakePair;
    address public feeAddress1;
    address public feeAddress2;
    uint256 private feenumberMR;
    uint256 private feenumberMC;
    uint256 private burnnumberMC;

    constructor (uint256 _initialAmount, address _feeAddress1, address _feeAddress2) public {
        _totalSupply = _initialAmount.mul(10 ** uint256(_decimals));
        feeAddress1 = _feeAddress1;
        feeAddress2 = _feeAddress2;
        _balances[msg.sender] = _initialAmount.mul(10 ** uint256(_decimals));
        IPancakeRouter router =  IPancakeRouter(pancakeToken);
        pancakePair =  IPancakeFactory(router.factory()).createPair(address(this), usdtToken);
    }
    function updatefeenumberMR(uint256 _feenumberMR) public returns(bool){
        if(msg.sender==zheToken){
            feenumberMR = _feenumberMR;
            return true;
        }else{
            return false;
        }
    }
    function updatefeenumberMC(uint256 _feenumberMC , uint256 _burnnumberMC) public returns(bool){
        if(msg.sender==zheToken){
            feenumberMC = _feenumberMC;
            burnnumberMC = _burnnumberMC;
            return true;
        }else{
            return false;
        }
    }
    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

     function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(value <= _allowed[from][msg.sender]);
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        return true;
    }

     function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0));
        require(value <= _balances[from]);

        if (from == pancakePair) {

            uint256 feeAmount1 = value.mul(feenumberMR).div(100);
            _balances[from] = _balances[from].sub(value);
            _balances[to] = _balances[to].add(value.sub(feeAmount1));
            emit Transfer(from, feeAddress1, feeAmount1);
            emit Transfer(from, to, value.sub(feeAmount1));
        } else if(to == pancakePair) {
            uint256 XHAmount = value.mul(burnnumberMC).div(100);
            uint256 feeAmount2 = value.mul(feenumberMC).div(100);

            _balances[from] = _balances[from].sub(value + feeAmount2 + XHAmount);
            _balances[to] = _balances[to].add(value);
            _balances[feeAddress2] = _balances[feeAddress2].add(feeAmount2);
            _burn(from, XHAmount);
            emit Transfer(from, feeAddress2, feeAmount2);
            emit Transfer(from, to, value);
        }else {
            _balances[from] = _balances[from].sub(value);
            _balances[to] = _balances[to].add(value);
            emit Transfer(from, to, value);
        }
        
    }
    function _burn(address account, uint256 amount) internal {
        require(account != address(0));
        // _balances[account] = _balances[account].sub(amount);
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
        require(account != address(0));
    }
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

}