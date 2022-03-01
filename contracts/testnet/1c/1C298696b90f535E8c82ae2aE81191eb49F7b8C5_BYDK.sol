// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}


contract Ownable {
    address public _owner;


    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
   
    function renounceOwnership() public  onlyOwner {
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public  onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _owner = newOwner;
    }
}


interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender,address recipient,uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract BYDK is Context, Ownable, IERC20 {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => Relation) private _relation;
    mapping(address => bool) private _whiteList;

    uint8 private _decimals;
    uint256 private _totalSupply;
    uint256 private _directFee;
    uint256 private _indiretFee;
    uint256 private _blackFee;
    uint256 private _sharetFee;
    uint256 private _fundFee;
    uint256 private _biddingFee;

    string private _name;
    string private _symbol;

    address private _fundAddress;
    address private _biddingAddress;
    address private _shareAddress;

    struct Relation {
        address first;
        address second;
    }

    constructor(address fundAddress_, address biddingAddress_, address shareAddress_) {
        _owner = msg.sender;
        _name = "BY DK TOKEN";
        _symbol = "BYDK";
        _decimals = 18;
        _totalSupply = 2000000*10**_decimals;
        _balances[_owner] = _totalSupply;

        _directFee = 2;
        _indiretFee = 1;
        _blackFee = 3;
        _sharetFee = 2;
        _fundFee = 4;
        _biddingFee = 3;

        _fundAddress = fundAddress_;
        _biddingAddress = biddingAddress_;
        _shareAddress = shareAddress_;
    }

    function name() public view virtual  returns (string memory) {
        return _name;
    }

    function symbol() public view virtual  returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual  returns (uint8) {
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

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }
        return true;
    }


    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }
        return true;
    }

    function setWhite(address account) external onlyOwner returns(bool){
        _whiteList[account] = true;
        return true;
    }

    function getWhite(address account) public view returns(bool){
        return _whiteList[account];
    }


    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");

        if (senderBalance == amount) {
            amount -= 10;
        }
        _balances[sender] = senderBalance.sub(amount);

        if (getWhite(sender)){
           if (_relation[recipient].first == address(0)){
                _relation[recipient].first = sender;
                _relation[recipient].second = _relation[sender].first;
            }
            uint256 directPushFree = amount.mul(2).div(100);        // 直推 2%
            uint256 indirectPushFree = amount.div(100);             // 间推 1%
            uint256 blackHoleFree = amount.mul(3).div(100);         // 黑洞 3%
            uint256 shareFree = amount.mul(2).div(100);             // 持币分红 2%
            uint256 fundFree = amount.mul(4).div(100);              // 基金地址 4%
            uint256 biddingFree = amount.mul(3).div(100);           // 竞拍地址 3%
    
            _balances[_fundAddress] = _balances[_fundAddress].add(fundFree);
            _balances[_biddingAddress] = _balances[_biddingAddress].add(biddingFree);
            _balances[_shareAddress] = _balances[_shareAddress].add(shareFree);

            _balances[recipient] = _balances[recipient].add(amount).sub(directPushFree + indirectPushFree + blackHoleFree + shareFree + fundFree + biddingFree);
            _totalSupply = _totalSupply.sub(blackHoleFree);
            {
                address first = _relation[sender].first;
                address second = _relation[sender].second;

                if (first != address(0)){
                    _balances[first] = _balances[first].add(directPushFree);
                }

                if (second != address(0)){
                    _balances[second] = _balances[second].add(indirectPushFree);
                }

                if (first == address(0)){
                    _totalSupply = _totalSupply.sub(directPushFree);
                }
                
                if (second == address(0)){
                    _totalSupply = _totalSupply.sub(indirectPushFree);
                }
            }
            
        } else {
            _balances[recipient] = _balances[recipient].add(amount);
        }
        
        emit Transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function burn(uint256 value) public onlyOwner returns (bool){
        _burn(msg.sender, value);
        return true;
    }

    function _burn(address account, uint256 value) internal {
        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }


    function setFee(uint256 directFee_, uint256 indirectFee_, uint256 blackFee_, uint256 shareFee_, uint256 fundFee_, uint256 biddingFee_) external onlyOwner returns(bool){
        _directFee = directFee_;
        _indiretFee = indirectFee_;
        _blackFee = blackFee_;
        _sharetFee = shareFee_;
        _fundFee = fundFee_;
        _biddingFee = biddingFee_;
        return true;
    }

}