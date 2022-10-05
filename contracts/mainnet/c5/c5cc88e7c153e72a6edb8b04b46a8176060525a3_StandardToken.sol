/**
 *Submitted for verification at BscScan.com on 2022-10-05
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-29
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract StandardToken is Context, IERC20, IERC20Metadata {

    string private _name;
    string private _symbol ;
    uint8 private _decimals = 18;
    uint256 private _totalSupply ;
    uint256 public totalBurn ;
    uint256 public burnNumber;
    uint256 public burnTime ;
    
    address private admin ;
    address private safeWallet ;

    mapping(address=>uint) private _balances ;
    mapping(address=>mapping(address=>uint)) private  _allowances ;
    bool mintingFinishedPermanent ;

    mapping(address=>invest) public investDetail ;
    struct invest {
        uint total ;  
        uint claimToken;   
        uint claimTime ;  
        bool status ; 
    }


    function name() public view virtual override returns (string memory) {
        return _name;
    }


    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }


    function decimals() public view virtual override returns (uint8) {
        return 18;
    }


    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }


    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }


    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }


    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }


    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }


    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }



    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender]+addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender]+subtractedValue);
        return true;
    }




    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }




    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _beforeTokenTransfer(sender, recipient, amount);
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

    function _mint(address account, uint256 amount) internal virtual {
        require(!mintingFinishedPermanent,"cant be minted anymore!");
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }


    function releaseInvest() public  {
        require(investDetail[msg.sender].status,"you are not investor!");
        require(block.timestamp >= investDetail[msg.sender].claimTime + 30 days,"haven't reach time to take the investment of token");
        require(investDetail[msg.sender].total >= investDetail[msg.sender].claimToken ,"it's empty,all investment of token have been released.");
        uint transferAmount;
        if(investDetail[msg.sender].claimTime == uint(0)){
            transferAmount =  (investDetail[msg.sender].total)/10;
        }else{
            transferAmount =  investDetail[msg.sender].claimToken ;
        }

        _balances[address(this)] -= transferAmount ;
        _balances[msg.sender] += transferAmount ;
        investDetail[msg.sender].total -= transferAmount;
        investDetail[msg.sender].claimTime = block.timestamp ;
    }



    function setInvestors(address _investor,uint _total,uint _release) public onlyAdmin {
        investDetail[_investor].status = true ;
        investDetail[_investor].total = _total * 10 ** _decimals ;
        investDetail[_investor].claimToken = _release * 10 ** _decimals;
    }



    function burnToken()public onlyAdmin{
        require(block.timestamp >= burnTime + 30 days,"need 30 dyas to burn again after last burn");
        require(totalBurn >= burnNumber,"No Token Can burn.");
        totalBurn = totalBurn - burnNumber ;
        burnTime = block.timestamp ;
        _burn(burnNumber);
    }

    function _burn( uint256 amount) internal onlyAdmin  {
        require(msg.sender != address(0), "ERC20: burn from the zero address");
        _beforeTokenTransfer(msg.sender, address(0), amount);
        uint256 accountBalance = _balances[address(this)];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[address(this)] = accountBalance - amount;
        _totalSupply -= amount;
        emit Transfer(address(this), address(0), amount);
    }

    receive() external payable {
        payable(admin).transfer(admin.balance);
    }


    constructor(uint _total,string memory _tokenName,string memory _tokenSymbol,address _safeWallet) {
        _total =  _total* (10**_decimals);
        admin = msg.sender ;
        safeWallet = _safeWallet ;
        _name = _tokenName;
        _symbol = _tokenSymbol ;
        _approve(address(this), admin, _total);
        _mint(address(this), _total/100*0); 
        _mint(_safeWallet, _total/100*100); 
        mintingFinishedPermanent  = true ;
        totalBurn = _total/2;
        burnNumber = totalBurn/3650*30;
    }


    function setSafeWallet(address _addr) public onlyAdmin {
        safeWallet = _addr ;
    }

    modifier onlyAdmin{
        require(msg.sender == admin);
        require(msg.sender != address(0));
        _;
    }

    function changeAdmin()public onlyAdmin{
        admin = msg.sender ;
    }



}