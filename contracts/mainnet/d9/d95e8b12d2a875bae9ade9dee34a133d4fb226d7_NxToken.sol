// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import "IERC20.sol";
import "Ownable.sol";
import "SafeMath.sol";
import "MemeberManage.sol";
import "Mode.sol";
import "IModeFunction.sol";

contract NxToken is IERC20, Ownable, MemeberManage, Mode {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;


    address public constant HOLE =
    address(0x000000000000000000000000000000000000dEaD);
    mapping (address => bool) private _feeWhiteList;

    uint256 private _minTotalSupply;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
        _mint(_msgSender(), 21 * 10**(uint256(_decimals) + 3));
        _minTotalSupply = 21 * 10**(uint256(_decimals) + 2);
    }


    receive() external payable {

    }
    function name() public view virtual returns (string memory) {
        return _name;
    }


    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }


    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }


    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }


    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }


    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);       
        return true;
    }


    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }


    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }


    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }


    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }


    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }


    function _checkAvailableTransferAndFee(address sender, address recipient, uint256 amount) private view returns (uint256 fee, uint256 rev,bool isHole) {
        if((_feeWhiteList[sender]||_feeWhiteList[recipient]) &&(sender==exchange||recipient==exchange)){
            isHole=false;
            fee = 0;
            rev = amount;
            return (fee,amount,isHole);
        }
        isHole=true;
        uint256 flowing = _totalSupply.sub(_balances[HOLE]);
        if (sender == exchange) {
            if(flowing > _minTotalSupply){
                fee = amount.mul(_transferHOLERate).div(RATE_PRECISION);
                if (flowing.sub(fee) < _minTotalSupply) {
                    fee = flowing.sub(_minTotalSupply);
                }
                rev = amount.sub(fee).sub(amount.mul(_transferFoundationRate.add(_gen1).add(_gen2).add(_gen3.mul(5))).div(RATE_PRECISION));
            }else{
                fee = 0;
                rev = amount.sub(fee).sub(amount.mul(_transferFoundationRate.add(_gen1).add(_gen2).add(_gen3.mul(5))).div(RATE_PRECISION));
                isHole=false;
            }

        }
        if(recipient==exchange ) {
            if(flowing > _minTotalSupply){
                fee = amount.mul(_transferHOLERate).div(RATE_PRECISION);
                if (flowing.sub(fee) < _minTotalSupply) {
                    fee = flowing.sub(_minTotalSupply);
                }
                rev = amount.sub(fee).sub(amount.mul(_transferFoundationRate.add(_gen1).add(_gen2).add(_gen3.mul(5))).div(RATE_PRECISION));
            }else{
                fee = 0;
                rev = amount.sub(fee).sub(amount.mul(_transferFoundationRate.add(_gen1).add(_gen2).add(_gen3.mul(5))).div(RATE_PRECISION));
                isHole=false;
            }

        }
        if(sender!=exchange&&recipient!=exchange){
            if(flowing > _minTotalSupply && amount>1*10**14){
                fee = amount.mul(_transferFeeRate2).div(RATE_PRECISION);
                if (flowing.sub(fee) < _minTotalSupply) {
                    fee = flowing.sub(_minTotalSupply);
                }
                rev = amount.sub(fee);
            }else{
                fee = 0;
                rev = amount;
                isHole=false;
            }
        }
    }


    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount>0,"amount:transfer 0 amount");
        if(!isExistEntry(sender)&&sender!=exchange){
            addMember(sender,defaultParent);
        }

        if(!isExistEntry(recipient)&&sender!=exchange){
            addMember(recipient,sender);
        }

        (uint256 fee, uint256 rev,bool isHole) = _checkAvailableTransferAndFee(sender, recipient, amount);
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(rev);
        emit Transfer(sender, recipient, rev);
        if((_feeWhiteList[sender]||_feeWhiteList[recipient]) && (exchange==sender||exchange==recipient)){
            return;
        }
        if(sender==exchange) {
            if(isHole && fee>0 ){
                _balances[HOLE] = _balances[HOLE].add(fee);
                emit Transfer(sender, HOLE,fee);
            }
            _balances[Foundation] = _balances[Foundation].add(amount.mul(_transferFoundationRate).div(RATE_PRECISION));
            emit Transfer(sender, Foundation, amount.mul(_transferFoundationRate).div(RATE_PRECISION));
            _sendToParents(sender,recipient,amount);

        }
        if(recipient==exchange ){
            if(isHole && fee>0){
                _balances[HOLE] = _balances[HOLE].add(fee);
                emit Transfer(sender, HOLE,fee);
            }
            _balances[Foundation] = _balances[Foundation].add(amount.mul(_transferFoundationRate).div(RATE_PRECISION));
            emit Transfer(sender, Foundation, amount.mul(_transferFoundationRate).div(RATE_PRECISION));
            _sendToParents(sender,sender,amount);
        }
        if(sender!=exchange&&recipient!=exchange){
            if(isHole && fee>0){
                _balances[HOLE] = _balances[HOLE].add(fee);
                emit Transfer(sender, HOLE,fee);
            }
        }

    }


    function isRealParent(address self)internal view returns (bool){
        uint256 flowing = _totalSupply.sub(_balances[HOLE]);
        return _balances[self]>flowing.mul(_holdingRate).div(HOLDING_RATE_PRECISION);
    }

    function _sendToParents(address sender,address recipient,uint256 amount) private{
        bool isExsited=false;
        isExsited=members[members[recipient].parent].isExsited;
        address parent=members[recipient].parent;
        uint256 i=0;
        while(isExsited&&parent!=address(0x0)){
            if(i==0){//1
                if(isRealParent(parent)){
                    _balances[parent] = _balances[parent].add(amount.mul(_gen1).div(RATE_PRECISION));
                    emit Transfer(sender, parent, amount.mul(_gen1).div(RATE_PRECISION));
                }else{
                    _balances[defaultParent] = _balances[defaultParent].add(amount.mul(_gen1).div(RATE_PRECISION));
                    emit Transfer(sender, defaultParent, amount.mul(_gen1).div(RATE_PRECISION));
                }

            }else if(i==1){//2
                if(isRealParent(parent)){
                    _balances[parent] = _balances[parent].add(amount.mul(_gen2).div(RATE_PRECISION));
                    emit Transfer(sender, parent, amount.mul(_gen2).div(RATE_PRECISION));
                }else{
                    _balances[defaultParent] = _balances[defaultParent].add(amount.mul(_gen2).div(RATE_PRECISION));
                    emit Transfer(sender, defaultParent, amount.mul(_gen2).div(RATE_PRECISION));
                }
            }else if(i>=2&&i<=6){//3-7
                if(isRealParent(parent)){
                    _balances[parent] = _balances[parent].add(amount.mul(_gen3).div(RATE_PRECISION));
                    emit Transfer(sender, parent, amount.mul(_gen3).div(RATE_PRECISION));
                }else{
                    _balances[defaultParent] = _balances[defaultParent].add(amount.mul(_gen3).div(RATE_PRECISION));
                    emit Transfer(sender, defaultParent, amount.mul(_gen3).div(RATE_PRECISION));
                }
            }
            i=i+1;
            if(i==7){
                break;
            }
            parent=members[parent].parent;
            isExsited=members[parent].isExsited;
        }
        if(i==0){
            _balances[defaultParent] = _balances[defaultParent].add(amount.mul(_gen1+_gen2+_gen3.mul(5)).div(RATE_PRECISION));
            emit Transfer(sender, defaultParent, amount.mul(_gen1+_gen2+_gen3.mul(5)).div(RATE_PRECISION));
        }else if(i==1){
            _balances[defaultParent] = _balances[defaultParent].add(amount.mul(_gen2+_gen3.mul(5)).div(RATE_PRECISION));
            emit Transfer(sender, defaultParent, amount.mul(_gen2+_gen3.mul(5)).div(RATE_PRECISION));
        }else if(i==2){
            _balances[defaultParent] = _balances[defaultParent].add(amount.mul(_gen3.mul(5)).div(RATE_PRECISION));
            emit Transfer(sender, defaultParent, amount.mul(_gen3.mul(5)).div(RATE_PRECISION));
        }else if(i==3){
            _balances[defaultParent] = _balances[defaultParent].add(amount.mul(_gen3.mul(4)).div(RATE_PRECISION));
            emit Transfer(sender, defaultParent, amount.mul(_gen3.mul(4)).div(RATE_PRECISION));
        }else if(i==4){
            _balances[defaultParent] = _balances[defaultParent].add(amount.mul(_gen3.mul(3)).div(RATE_PRECISION));
            emit Transfer(sender, defaultParent, amount.mul(_gen3.mul(3)).div(RATE_PRECISION));
        }else if(i==5){
            _balances[defaultParent] = _balances[defaultParent].add(amount.mul(_gen3.mul(2)).div(RATE_PRECISION));
            emit Transfer(sender, defaultParent, amount.mul(_gen3.mul(2)).div(RATE_PRECISION));
        }else if(i==6){
            _balances[defaultParent] = _balances[defaultParent].add(amount.mul(_gen7).div(RATE_PRECISION));
            emit Transfer(sender, defaultParent, amount.mul(_gen7).div(RATE_PRECISION));
        }
    }


    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }


    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _balances[account] = _balances[account].sub(amount, "ERC20: burn");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }


    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20:zero");
        require(spender != address(0), "ERC20:zero");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }


    function _setupDecimals(uint8 decimals_) internal virtual {
        _decimals = decimals_;
    }


    function minTotalSupply() public view returns(uint256) {
        return _minTotalSupply;
    }

    function setMinTotalSupply(uint256 minTotalSupply_) public onlyOwner {
        _minTotalSupply = minTotalSupply_;
    }

    function addFeeWhiteList(address[] memory whos) public onlyOwner {
        for(uint256 i=0;i<whos.length;i++){
            _feeWhiteList[whos[i]] = true;
        }

    }

    function rmFeeWhiteList(address[] memory whos) public onlyOwner {
        for(uint256 i=0;i<whos.length;i++){
            _feeWhiteList[whos[i]] = false;
        }
    }    

}