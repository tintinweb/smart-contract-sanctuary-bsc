// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import "./SafeMath.sol";
import "./Address.sol";
import "./Math.sol";
import "./Context.sol";
import "./IERC20.sol";

import "./SafeOwnable.sol";
import "./IDayOfRightsClub.sol";
import "./IReferral.sol";
import "./IFactory.sol";
import "./IRouter.sol";
import "./console.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping(address => uint256) internal _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 internal _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
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
    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
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
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
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
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(
            amount,
            "ERC20: transfer amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(
            amount,
            "ERC20: burn amount exceeds balance"
        );
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
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
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal virtual {
        _decimals = decimals_;
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}


interface IMdexFactory {

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) external view returns (uint256 amountOut);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
}


contract CosmicHunterToken is ERC20, SafeOwnable {
    using SafeMath for uint256;
    using Address for address;
    uint256 public constant BASE_RATIO = 10 ** 18;
    uint256 public constant MAX_FEE = (42 * BASE_RATIO) / 100;
  
    mapping(address => bool) private minner;
    mapping(address => bool) public whitelist;
    mapping(address => bool) public blacklist;
    bool public onlyWhite = true;
  
    uint256 public buyBurnFee = (1 * BASE_RATIO) / 100;
    address public burnAddr = address(0xdead);

    uint256 public buyLpFee= (2 * BASE_RATIO) / 100;
    address public lpAddr = 0x425843226559E5cDDccec601F548c934d8235ED7;

    uint256 public buyConFee = (1 * BASE_RATIO) / 100;
    address public conAddr = 0x2C4aBA93227A2225b7b6B750431966F061701014;

    uint256 public buyGalFee = (2 * BASE_RATIO) / 100;
    address public galAddr = 0x7e90BeEd409d4B3897760fAFdDdce81cF801fB94;

    uint256 public inviteFee = (4 * BASE_RATIO) / 100;
    address public inviteAddr = 0xaB23a552f9B89F8Be8e9f2223f1af02C52D9ed6A;

    uint256 public currentBuyFee =
      buyBurnFee + buyLpFee + buyConFee + buyGalFee + inviteFee;

    uint256 public sellBurnFee = (2 * BASE_RATIO) / 100;  
    uint256 public sellLpFee= (2 * BASE_RATIO) / 100;
   
    uint256 public mtFee = (1 * BASE_RATIO) / 100;
    address public mtAddr = 0x7BFA64E4c30b6f53e9a2D2e011c3a45e5Ef65305;
    uint256 public sellConFee = (1 * BASE_RATIO) / 100;
    uint256 public sellGalFee = (3 * BASE_RATIO) / 100;

    uint256 public fomoFee2 = (2 * BASE_RATIO) / 100;
    address public fomoAddr2 = 0x98ad799D605Cc17B2D375f5A9cf6c35aDEcB6Dd8;
    uint256 public fomoFee1 = (1 * BASE_RATIO) / 100;
    address public fomoAddr1 = 0x5A8749916D46Add264c6e9FB69B73410BD83b5Ee;
    uint256 public currentSellFee =
      sellBurnFee + sellLpFee + mtFee+ sellConFee + sellGalFee + fomoFee2 + fomoFee1;

    bool public canTransfer = true;

    address public  immutable _mdexFactory;
    address public immutable _pairFactory;
    bool public _canGetPrice = false;
    uint256 _basePrice = 0.2*10**18;
    uint256 _maxRate = 900;

    IERC20 public usdtToken;
    address public liquidity;
   
    event AddWhitelist(address account);
    event DelWhitelist(address account);
    event ChangePriceLog(uint256 indexed price);

    address public initIdo = 0xAE6034dcb7AabA54139b059D4Fd00B37cA40Ab9b; 
    address public initEco = 0x95D030E336d4a03146b678B08115075C4eBb7Ecd;

    uint256[] public boom = [0.1*10**18,0.05*10**18,0.025*10**18];
    uint256[] public boomFee = [(12 * BASE_RATIO) / 100,(22 * BASE_RATIO) / 100,(32 * BASE_RATIO) / 100];

    constructor(
        address _usdtToken,
        IFactory _factory,
        IRouter _router
    ) ERC20("Cosmic Hunter Token", "COS") {
        _setupDecimals(uint8(18));
        usdtToken = IERC20(_usdtToken);

        liquidity = _factory.createPair(address(this), _usdtToken);
       
        _mdexFactory = address(_router);
        _pairFactory = address(_factory);

        minner[owner()] = true;
     
        whitelist[initIdo] = true;
        whitelist[initEco] = true;
        whitelist[address(this)] = true;
        whitelist[address(0)] = true;
        whitelist[burnAddr] = true;
        whitelist[lpAddr] = true;
        whitelist[conAddr] = true;
        whitelist[galAddr] = true;
        whitelist[inviteAddr] = true;
        whitelist[mtAddr] = true;
        whitelist[fomoAddr2] = true;
        whitelist[fomoAddr1] = true;
        whitelist[owner()] = true;

        uint256 total = 42000000 * BASE_RATIO;
        _totalSupply = _totalSupply.add(total);
        
        uint256 amount = 10000000 * BASE_RATIO;
        _balances[initIdo] = _balances[initIdo].add(amount);
        emit Transfer(address(0), initIdo, amount);
        _balances[initEco] = _balances[initEco].add(total.sub(amount));
        emit Transfer(address(0), initEco, total.sub(amount));
    }

    function setBuyFeePercent(uint256 percent,uint _type)
        external
        onlyOwner 
        returns (bool) {
         if (_type == 0) {
           buyBurnFee = percent;
        } else if (_type == 1) {
           buyLpFee = percent;
        } else if (_type == 2) {
           buyConFee = percent;
        } else if (_type == 3) {
           buyGalFee = percent;
        } else if (_type == 4) {
           inviteFee = percent;
        }
        return true;
    }

     function setSellFeePercent(uint256 percent,uint _type)
        external
        onlyOwner 
        returns (bool) {
         if (_type == 0) {
           sellBurnFee = percent;
        } else if (_type == 1) {
           sellLpFee = percent;
        } else if (_type == 2) {
           sellConFee = percent;
        } else if (_type == 3) {
           sellGalFee = percent;
        } else if (_type == 4) {
           fomoFee2 = percent;
        } else if (_type == 5) {
           fomoFee1 = percent;
        }
        return true;
    }

    function setFeeAddr(address _addr,uint _type) 
        external 
        onlyOwner 
        returns (bool) {
        if (_type == 0) {
           lpAddr = _addr;
        } else if (_type == 1) {
            conAddr = _addr;
        } else if (_type == 2) {
            galAddr = _addr;
        } else if (_type == 3) {
            inviteAddr = _addr;
        } else if (_type == 4) {
            mtAddr = _addr;
        } else if (_type == 5) {
            fomoAddr2 = _addr;
        } else if (_type == 6) {
            fomoAddr1 = _addr;
        }
        return true;
    }

    function setOnlyWhite(bool _flag) public onlyOwner returns (bool) {
        onlyWhite = _flag;
        return true;
    }

    function setBoom (uint256[] calldata _nBoom) public onlyOwner returns (bool) {
        boom = _nBoom;
        return true;
    }

    function setCanTransfer(bool enable) external onlyOwner {
        canTransfer = enable;
    }

    function setCanGetPrice(bool enable) external onlyOwner returns (bool){
        _canGetPrice = enable;
        return true;
    }

    function setMaxRate(uint256 _nRate) external onlyOwner returns (bool) {
        _maxRate = _nRate;
        return true;
    }

    function changeBasePrice() external returns (bool){
        require (whitelist[_msgSender()],"BEP20: not whitelist");
        _basePrice = getPrice();
        boom = [_basePrice.mul(50).div(100),_basePrice.mul(25).div(100),_basePrice.mul(125).div(1000)];
        emit ChangePriceLog(_basePrice);
        return true;
    }  
   

    function setMinner(address _minner, bool enable) external onlyOwner {
        minner[_minner] = enable;
    }

    function isMinner(address account) public view returns (bool) {
        return minner[account];
    }

    modifier onlyMinner() {
        require(isMinner(msg.sender), "caller is not minter");
        _;
    }

    function addWhitelist(address _addr) external onlyOwner {
        whitelist[_addr] = true;
        emit AddWhitelist(_addr);
    }

    function delWhitelist(address _addr) external onlyOwner {
        delete whitelist[_addr];
        emit DelWhitelist(_addr);
    }

    function modifyWhitelist(address[] calldata _addrs,bool _flag) external onlyOwner {
        for(uint256 i=0;i<_addrs.length;i++){
            whitelist[_addrs[i]] = _flag;
        }
    }

    function modifyBlacklist(address[] calldata _addrs,bool _flag) external onlyOwner {
        for(uint256 i=0;i<_addrs.length;i++){
            blacklist[_addrs[i]] = _flag;
        }
    }

    function mint(address to, uint256 value) external onlyMinner {
        _mint(to, value);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        address account = from == liquidity ? to : from;
        if (onlyWhite) {
            require (whitelist[account],"BEP20: not whitelist");
        }
        require (!blacklist[account],"BEP20: blacklist");
        if (from == liquidity || to == liquidity) {
           if (!whitelist[account]) {
             if (to == liquidity) {
                uint256 maxAmount = _balances[account].mul(_maxRate).div(1000);
                require (maxAmount >= amount,"BEP20:amount error");
             }
             amount = calculateFee(from, amount,to==liquidity);
           }
        } else {
            if (!whitelist[account]) {
                uint256 maxAmount = _balances[account].mul(_maxRate).div(1000);
                require (maxAmount >= amount,"BEP20:amount error");
                amount = calculateFeeSell(from, amount,false);
            }
        }
        super._transfer(from, to, amount);
    }

   

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        require(
            canTransfer || whitelist[sender] || whitelist[recipient],
            "can not transfer"
        );
        return super.transferFrom(sender, recipient, amount);
    }


    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        require(
            canTransfer || whitelist[recipient] || whitelist[_msgSender()],
            "can not transfer"
        );
        return super.transfer(recipient, amount);
    }

    function calculateFee(
        address from,
        uint256 amount,
        bool isSell
    ) internal returns (uint256) {
        if (isSell) {
           return calculateFeeSell(from,amount,true);
        } else {
           return calculateFeeBuy(from,amount);
        }
    }
   
    //buyBurnFee + buyLpFee + buyConFee + buyGalFee + inviteFee;
    function calculateFeeBuy (address from,uint256 amount) internal returns (uint256) {
        uint256 realAmount = amount;
        address account = from;
        uint256 tBurn = amount.mul(buyBurnFee).div(BASE_RATIO);
        if (tBurn > 0) {
            realAmount = realAmount.sub(tBurn);
            super._transfer(account, burnAddr, tBurn);
        }
        uint256 tLp = amount.mul(buyLpFee).div(BASE_RATIO);
        if (tLp > 0) {
            realAmount = realAmount.sub(tLp);
            super._transfer(account, lpAddr, tLp);
        }
        uint256 tCon = amount.mul(buyConFee).div(BASE_RATIO);
        if (tCon > 0) {
            realAmount = realAmount.sub(tCon);
            super._transfer(account, conAddr, tCon);
        }
        uint256 tGal = amount.mul(buyGalFee).div(BASE_RATIO);
        if (tGal > 0) {
            realAmount = realAmount.sub(tGal);
            super._transfer(account, galAddr, tGal);
        }
        uint256 tInv = amount.mul(inviteFee).div(BASE_RATIO);
        if (tInv > 0) {
            realAmount = realAmount.sub(tInv);
            super._transfer(account, inviteAddr, tInv);
        }
        return realAmount;
    }

     //sellBurnFee + sellLpFee + mtFee + sellConFee + sellGalFee + fomoFee2 + fomoFee1;
    function calculateFeeSell (address from,uint256 amount,bool readPrice) internal returns (uint256) {
        uint256 realAmount = amount;
        address account = from;

        uint256 tBurnFee = sellBurnFee;
        if (_canGetPrice  && readPrice) {
            tBurnFee = getSellBurnFee();
        }
        if (amount.mul(tBurnFee).div(BASE_RATIO) > 0) {
            realAmount = realAmount.sub(amount.mul(tBurnFee).div(BASE_RATIO));
            super._transfer(account, burnAddr, amount.mul(tBurnFee).div(BASE_RATIO));
        }
       
        uint256 tLp = amount.mul(sellLpFee).div(BASE_RATIO);
        if (tLp > 0) {
            realAmount = realAmount.sub(tLp);
            super._transfer(account, lpAddr, tLp);
        }
        uint256 tMt = amount.mul(mtFee).div(BASE_RATIO);
        if (tMt > 0) {
            realAmount = realAmount.sub(tMt);
            super._transfer(account, mtAddr, tMt);
        }
        uint256 tCon = amount.mul(sellConFee).div(BASE_RATIO);
        if (tCon > 0) {
            realAmount = realAmount.sub(tCon);
            super._transfer(account, conAddr, tCon);
        }
        uint256 tGal = amount.mul(sellGalFee).div(BASE_RATIO);
        if (tGal > 0) {
            realAmount = realAmount.sub(tGal);
            super._transfer(account, galAddr, tGal);
        }
        uint256 tFomo2 = amount.mul(fomoFee2).div(BASE_RATIO);
        if (tFomo2 > 0) {
            realAmount = realAmount.sub(tFomo2);
            super._transfer(account, fomoAddr2, tFomo2);
        }
        uint256 tFomo1 = amount.mul(fomoFee1).div(BASE_RATIO);
        if (tFomo1 > 0) {
            realAmount = realAmount.sub(tFomo1);
            super._transfer(account, fomoAddr1, tFomo1);
        }
        return realAmount;
    }

    
    function getSellBurnFee() public view returns (uint256) {
        uint256 price = getPrice();
        if (price >= boom[0]){
            return sellBurnFee;
        } else if (price < boom[0] && price >= boom[1]) {
            return boomFee[0];
        } else if (price < boom[1] && price >= boom[2]) {
            return boomFee[1];
        } else if (price < boom[2]) {
            return boomFee[2];
        }
        return sellBurnFee;
    } 

    function getPrice () public view returns (uint256) {
        (address token0,) = sortTokens(address(this), address(usdtToken));
        address pairToken = getPair(address(this), address(usdtToken));
        IMdexFactory pairFactory = IMdexFactory(pairToken);
        (uint reserve0, uint reserve1, ) = pairFactory.getReserves();
        IMdexFactory mDexFactory = IMdexFactory(_mdexFactory);
        (uint reserveInput, uint reserveOutput) = address(this) == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
        return mDexFactory.getAmountOut(BASE_RATIO, reserveInput, reserveOutput);
    }

    function sortTokens(address tokenA, address tokenB) public pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'PancakeLibrary: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'PancakeLibrary: ZERO_ADDRESS');
    }
    function getPair(address tokenA, address tokenB) public view returns (address) {
        IMdexFactory factory = IMdexFactory(_pairFactory);
        return factory.getPair(tokenA, tokenB);
    }

}