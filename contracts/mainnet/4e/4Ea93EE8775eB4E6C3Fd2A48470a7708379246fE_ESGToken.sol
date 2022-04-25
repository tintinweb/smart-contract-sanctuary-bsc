/**
 *Submitted for verification at BscScan.com on 2022-04-25
*/

/**
 *Submitted for verification at BscScan.com on 2021-10-04
*/

//SPDX-License-Identifier: MIT
//Dev @interfinetwork

pragma solidity ^0.6.12;

interface SwapInterface {
    function swapTokensForEth() external;
    }

interface IBEP20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    function showRefer(address account) external view returns (address);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    event Burn(address indexed owner, address indexed to, uint value);
}

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint a, uint b) internal pure returns (uint) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b <= a, errorMessage);
        uint c = a - b;

        return c;
    }
    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }

        uint c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint a, uint b) internal pure returns (uint) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint c = a / b;

        return c;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

}


library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
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
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


contract BEP20 is Context, Ownable, IBEP20{
    using SafeMath for uint;
    using Address for bool;

    mapping (address => uint) internal _balances;
    mapping (address => address) internal refer;
    mapping (address => mapping (address => uint)) internal _allowances;

    


    uint internal totalBurn;
    uint public deployTime;
    
    uint internal _totalSupply;
    uint internal taxPer=50;


    uint internal min=10*10**18;
    mapping (address => bool) public isBlackListed;


    mapping(address => bool) public isExcluded;
    uint[] public REFERRAL_PERCENTS = [5];

    event RefBonus(address indexed referrer, address indexed referral, uint indexed level, uint amount);
    event AddedBlackList(address indexed _maker);
    event RemovedBlackList(address indexed _clearedUser);


    address public swapAddress=0xCa178373208e390d8F901C89d4FA7c583888A50f;  // transition address
    mapping (address => bool) public teams;


    address public deadAddress = 0x000000000000000000000000000000000000dEaD;
    address public preAddress = 0xb036dDB152786c31F83f3B273A73cf9d643E46Ef;

    address public old = 0x360c3962903F60424575349313331FDcf2F619cB;
    

   function contains(address _team) public view returns  (bool){
        return teams[_team];
    }

  
    function totalSupply() public view override returns (uint) {
        return _totalSupply;
    }
    function totalBurned() public view  returns (uint) {
        return totalBurn;
    }
    function taxPers() public view  returns (uint) {
        return taxPer;
    }
    function balanceOf(address account) public view override returns (uint) {
        return _balances[account];
    }
    function showRefer(address account) public view override  returns (address) {
        return refer[account];
    }
    function transfer(address recipient, uint amount) public override  returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address towner, address spender) public view override returns (uint) {
        return _allowances[towner][spender];
    }
    function approve(address spender, uint amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint amount) public override returns (bool) {
        // if (sender == D && !isOpenTrading) {
        //     isOpenTrading = true;
        // }
        // require(isOpenTrading, "Currently not open for trading");
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }
    function increaseAllowance(address spender, uint addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
    }
    // function _swap() internal {
    //     uint per=totalBurn.div(deNum).mul(12);
    //     uint temp=taxInitPer.sub(per);
    //     if(temp>=taxLimit){
    //         taxPer=temp;
    //     }else{
    //        taxPer=taxLimit; 
    //     }     
    // }

    /**
     * @dev Burn `amount` tokens and decreasing the total supply.
     */
    function burn(uint256 amount) public returns (bool) {
        _burn(_msgSender(), amount);
        return true;
    }
    function addisExcluded(address gameAddress) external onlyOwner {
        require(!isExcluded[gameAddress], "address already in allow list");
        // add gameAddress to allowedGameAddress
        isExcluded[gameAddress] = true;

    }
    function _checkrefer(address sender,address recipient) public view returns (bool) {
        if (sender != address(0)) {
            address upline = refer[sender];
            for (uint i = 0; i < 10; i++) {
                if (upline != recipient) {
                    upline = refer[upline];
                } else {
                    return true;
                }
            }
        }
        return false;
    }
    function _payRefer(address sender,address recipient,uint256 _value) internal returns (bool) {
        uint256 val=_value;

        if ( sender != address(0)) {
            address upline=refer[sender];
            if(teams[sender]){
                upline=refer[recipient];
            }
            for (uint i = 0; i <1 ; i++) {
                if (upline != address(0)) {
                    uint amount = _value;
                    if (amount > 0) {
                        //address(uint160(upline)).transfer(amount);
                        _balances[upline] = _balances[upline].add(amount);
                        val=val.sub(amount);
                        emit RefBonus(upline, sender, i, amount);
                        emit Transfer(sender, upline, amount);
                    }
                    upline = refer[upline];
                } else break;
            }
            if(val>0){
             totalBurn = totalBurn.add(val);
            _totalSupply = _totalSupply.sub(val);            
            emit Transfer(sender, address(0), val);
            } 
        }
        
    }
    function getBlackListStatus(address _maker) external view  returns (bool) {
        return isBlackListed[_maker];
    }
    
    function addBlackList (address _evilUser) public onlyOwner {
        isBlackListed[_evilUser] = true;
        emit AddedBlackList(_evilUser);
    }

    function removeBlackList (address _clearedUser) public onlyOwner {
        isBlackListed[_clearedUser] = false;
        emit RemovedBlackList(_clearedUser);
    }
    function _transfer(address sender, address recipient, uint amount) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(!isBlackListed[recipient]&&!isBlackListed[sender]);
        //uint max=_balances[sender].mul(999).div(1000);
        //require(amount <= max, "BEP20: transfer over limit");
        uint256 tax=amount.mul(taxPer).div(1000);
        if (refer[recipient] == address(0)  && sender != recipient && !Address.isContract(recipient)&& !Address.isContract(sender) && amount>=min) {
            bool res=_checkrefer(sender,recipient);
            if(!res){
                refer[recipient] = sender;
            }
        }

        if (isExcluded[sender] || isExcluded[recipient] ) {
            tax = 0;
        }
        uint256 netAmount = amount - tax;
   
        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");

        if (tax > 0) {
            uint256 taxM = tax.mul(30).div(50);
            uint256 taxR = tax.mul(20).div(50);
            _balances[preAddress] = _balances[preAddress].add(taxM);
            _balances[address(0)] = _balances[address(0)].add(taxR);
            totalBurn = totalBurn.add(taxR);
            _totalSupply = _totalSupply.sub(taxR);
            emit Transfer(sender, preAddress, taxM);
            emit Transfer(sender, address(0), taxR);

        }

        _balances[recipient] = _balances[recipient].add(netAmount);
        
        if (recipient == address(0) || recipient == deadAddress) {
            totalBurn = totalBurn.add(netAmount);
            _totalSupply = _totalSupply.sub(netAmount);

            emit Burn(sender, address(0), netAmount);
        }
        emit Transfer(sender, recipient, netAmount);
  
    }
 
    function _approve(address towner, address spender, uint amount) internal {
        require(towner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[towner][spender] = amount;
        emit Approval(towner, spender, amount);
    }
    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");
        totalBurn = totalBurn.add(amount);

        _balances[account] = _balances[account].sub(
            amount,
            "BEP20: burn amount exceeds balance"
        );
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

}

contract BEP20Detailed is BEP20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory tname, string memory tsymbol, uint8 tdecimals) internal {
        _name = tname;
        _symbol = tsymbol;
        _decimals = tdecimals;
        
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

contract ESGToken is BEP20Detailed {

    constructor() BEP20Detailed("ESG", "ESG", 18) public {
        deployTime = block.timestamp;
        _totalSupply = 20000000 * (10**18);
	    _balances[_msgSender()] = _totalSupply;
        refer[_msgSender()]=deadAddress;
	    emit Transfer(address(0), _msgSender(), _totalSupply);
    }
    function setSwapAddress(address _newAddress) external onlyOwner {
        swapAddress = _newAddress;
    }
    function setPreAddress(address _newAddress) external onlyOwner {
        preAddress = _newAddress;
    }
    function setInviteLimitValue(uint _value) external onlyOwner {
        min = _value;
    }
    function setTeams(address _value) external onlyOwner {
        if(!teams[_value]){
         teams[_value]=true;
       }
    }
    function setOld(address _value) external onlyOwner {
        old=_value;
    }
    function outTeams(address _value) external onlyOwner {
        if(teams[_value]){
         teams[_value]=false;
       }
    }
    
    
  
    function takeOutTokenInCase(address _token, uint256 _amount, address _to) public onlyOwner {
        IBEP20(_token).transfer(_to, _amount);
    }
}