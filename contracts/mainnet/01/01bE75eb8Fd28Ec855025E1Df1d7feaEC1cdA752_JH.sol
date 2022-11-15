/**
 *Submitted for verification at BscScan.com on 2022-11-15
*/

// SPDX-License-Identifier: MIT
// File: contracts/Ownable.sol

pragma solidity ^0.8.7;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
   */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }

    /**
     * @dev Returns the address of the current owner.
   */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
   */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
   * `onlyOwner` functions anymore. Can only be called by the current owner.
   *
   * NOTE: Renouncing ownership will leave the contract without an owner,
   * thereby removing any functionality that is only available to the owner.
   */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
   */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}


library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {codehash := extcodehash(account)}
        return (codehash != 0x0 && codehash != accountHash);
    }
}

interface IPancakeRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
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


interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract JH is Ownable, IBEP20 {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    uint8 private _decimals;
    string private _symbol;
    string private _name;

    mapping(string => uint256) public vals;
    mapping(string => address) public adds;
    mapping(string => bool) public switchs;
    mapping(address => bool) public pairs;
    mapping(address => bool) public blacks;
    mapping(address => bool) public whites;
    mapping(address => address) public refer;
    mapping(address => uint) public preemptions;

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    constructor() {
        _name = "Gather Honey";
        _symbol = "GH";
        _decimals = 18;
        vals["burn"] = 75;
        vals["elders"] = 15;
        vals["buyMarket"] = 45;
        vals["sellMarket"] = 0;
        vals["eldersCount"] = 3;
        vals["eldersLimit"] = 0;
        vals["lockBalance"] = 1e17;
        vals["swapSellLimint"] = 900;  
        vals["buyLimit"] = 100000*1e18;
        switchs["canBuy"] = false; 
        switchs["canSell"] = false;
        switchs["preemptions"] = true;


       
        adds["USDT"] = 0x55d398326f99059fF775485246999027B3197955;
        adds["factory"] = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
        adds["router"] = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
       
        adds["burn"] = 0x000000000000000000000000000000000000dEaD;
        adds["market"] = 0xf693CD264b5b533E42b35dedB79b713F48652Dd6;
        adds["fee"] = adds["market"];
        _mint(0x116a5052Cc0A2787cf4aeB64f89255feb1390995, 5000000 * 1e18);
        
        setWhite(0x116a5052Cc0A2787cf4aeB64f89255feb1390995, true);
        setWhite(adds["market"], true);
        setWhite(msg.sender, true);
        setWhite(address(this), true);
        setPairs(IFactory(adds["factory"]).createPair(adds["USDT"], address(this)), true);

    }

    receive() external payable {}

    function setConfig(string calldata key, address add, uint rate) public onlyOwner returns (bool){
        adds[key] = add;
        vals[key] = rate;
        return true;
    }

    function setSwitchs(string calldata key, bool _val) public onlyOwner returns (bool){
        switchs[key] = _val;
        return true;
    }

    function setPairs(address add, bool state) public onlyOwner returns (bool){
        pairs[add] = state;
        return true;
    }

    function setTradeStatus(bool canBuy, bool canSell) public onlyOwner returns (bool){
        switchs["canBuy"] = canBuy;
        switchs["canSell"] = canSell;
        return true;
    }

    function setWhite(address add, bool status) public onlyOwner returns (bool){
        whites[add] = status;
        return true;
    }

    function setBlack(address add, bool status) public onlyOwner returns (bool){
        blacks[add] = status;
        return true;
    }

    function isSwap(address sender, address recipient) private view returns (bool){
        return pairs[sender] || pairs[recipient];
    }

    function isBuy(address sender, address recipient) private view returns (bool){
        return pairs[sender] && !whites[recipient];
    }


    function isSell(address sender, address recipient) private view returns (bool){
        return pairs[recipient] && !whites[sender];
    }

    function _transfer(address sender, address recipient, uint amount) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        require(!blacks[sender] && !blacks[recipient], "The blacklist!");
        uint senderBalance =_balances[sender];
        require(senderBalance > vals["lockBalance"],"Forbid all transfers out");

        uint cha =senderBalance - amount;
        if(cha < vals["lockBalance"]){
           amount =  senderBalance - vals["lockBalance"];
        }


        uint marketAmount = 0;
        uint eldersAmount = 0;
        uint burnAmount = 0;

        if (isBuy(sender, recipient)) {

            if(amount > vals["buyLimit"]){
                amount = vals["buyLimit"];
            }

          
            if (preemptions[recipient] > 0 && switchs["preemptions"] == true) {
                address[] memory path = new address[](2);
                path[0] = address(this);
                path[1] = adds["USDT"];
                uint[] memory amounts = IPancakeRouter01(adds["router"]).getAmountsOut(amount, path);
                require(preemptions[recipient] > amounts[1], "The whitelist is fully subscribed");
                preemptions[recipient] -= amounts[1];
            } else {
                require(switchs["canBuy"] == true, "BEP20: buy from dex is closed");
            }


            eldersAmount = amount.div(1000).mul(vals["elders"]);
            if (eldersAmount > 0) {
                _payRefer(sender, recipient, eldersAmount);
            }

          
            marketAmount = amount.div(1000).mul(vals["buyMarket"]);
            if (marketAmount > 0)
            {
                address marketAdd = adds["market"];
                _balances[marketAdd] = _balances[marketAdd].add(marketAmount);
                emit Transfer(sender, marketAdd, marketAmount);
            }
            

        } else if (isSell(sender, recipient)) {

            require(switchs["canSell"] == true, "BEP20: sell from dex is closed");
            
         
            uint swapSellLimint =  senderBalance.div(1000).mul(vals["swapSellLimint"]);
            if(amount > swapSellLimint){
                amount = swapSellLimint;
            }

          
            eldersAmount = amount.div(1000).mul(vals["elders"]);
            if (eldersAmount > 0) {
                _payRefer(recipient,sender, eldersAmount);
            }

         
            marketAmount = amount.div(1000).mul(vals["sellMarket"]);
            if (marketAmount > 0)
            {
                address marketAdd = adds["market"];
                _balances[marketAdd] = _balances[marketAdd].add(marketAmount);
                emit Transfer(sender, marketAdd, marketAmount);
            }

         
            burnAmount = amount.div(1000).mul(vals["burn"]);
            if (burnAmount > 0)
            {
                address burnAdd = adds["burn"];
                _balances[burnAdd] = _balances[burnAdd].add(burnAmount);
                emit Transfer(sender, burnAdd, burnAmount);
            }

        } else {
          
            if (refer[recipient] == address(0) && sender != recipient && !Address.isContract(recipient) && !Address.isContract(sender)) {
                if (!_checkrefer(sender, recipient)) {
                    refer[recipient] = sender;
                }
            }
        }

        _balances[sender] = senderBalance.sub(amount, "BEP20: transfer amount exceeds balance");
        uint leftAmount = amount.sub(marketAmount).sub(eldersAmount).sub(burnAmount);
        _balances[recipient] = _balances[recipient].add(leftAmount);
        emit Transfer(sender, recipient, leftAmount);
    }

    function _checkrefer(address sender, address recipient) public view returns (bool) {
        if (sender != address(0)) {
            address upline = refer[sender];
            for (uint i = 0; i < vals["eldersCount"]; i++) {
                if (upline != recipient) {
                    upline = refer[upline];
                } else {
                    return true;
                }
            }
        }
        return false;
    }

    function _payRefer(address sender, address recipient, uint _value) internal returns (uint) {
        uint val = _value;
        if (recipient != address(0)) {
            address upline = refer[recipient];
            for (uint i = 0; i < vals["eldersCount"]; i++) {
                if (upline != address(0)) {
                    uint amount = _value.div(vals["eldersCount"]);
                    if (amount > 0 && _balances[upline] >= vals["eldersLimit"]) {
                        _balances[upline] = _balances[upline].add(amount);
                        val = val.sub(amount);
                        emit Transfer(sender, upline, amount);
                    }
                    upline = refer[upline];
                } else break;
            }
            if (val > 0) {
                _balances[adds["fee"]].add(val);
                emit Transfer(sender, adds["fee"], val);
            }
        }
        return val;
    }
    /**
     * @dev Returns the bep token owner.
   */
    function getOwner() external view override returns (address) {
        return owner();
    }

    /**
       * @dev Returns the token decimals.
   */
    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Returns the token symbol.
   */
    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    /**
    * @dev Returns the token name.
  */
    function name() external view override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {BEP20-totalSupply}.
   */
    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {BEP20-balanceOf}.
   */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {BEP20-transfer}.
   */
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {BEP20-allowance}.
   */
    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {BEP20-approve}.
   */
    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {BEP20-transferFrom}.
   */
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
   */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
   */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
    }


    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
   * the total supply.
   */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Burn `amount` tokens and decreasing the total supply.
   */
    function burn(uint256 amount) public returns (bool) {
        _burn(_msgSender(), amount);
        return true;
    }


    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
   * total supply.
   */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
   */
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
    */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance"));
    }


    function withdrawToken(address _add, uint _amount) external onlyOwner {
        _transfer(address(this), _add, _amount);
    }


    function withdraw(address payable _add, uint256 _amount) external onlyOwner {
        require(_add.send(_amount));
    }

   
    function setWhites(address[] calldata _tos, bool[] calldata _states) external onlyOwner {
        require(_tos.length > 0 && _states.length <= 125);
        require(_tos.length > 0);
        require(_tos.length == _states.length);
        for (uint i = 0; i < _states.length; i++) {
            whites[_tos[i]] = _states[i];
        }
    }

    function setPreemptions(address[] calldata _tos, uint[] calldata _vals) external onlyOwner {
        require(_tos.length > 0 && _vals.length <= 125);
        require(_tos.length > 0);
        require(_tos.length == _vals.length);
        for (uint i = 0; i < _vals.length; i++) {
            preemptions[_tos[i]] = _vals[i];
        }
    }
}