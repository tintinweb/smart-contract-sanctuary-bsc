// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./IERC20.sol";
import "./IERC20Metadata.sol";
import "./SafeMath.sol";
import "./Address.sol";
import "./AccessControl.sol";

import "./IUniswapV2Factory.sol";
import "./IUniswapV2Pair.sol";
import "./IUniswapV2Router02.sol";



contract DragonLeeToken is AccessControl, IERC20 {
    using SafeMath for uint256;
    using Address for address;

    bytes32 public constant NEW_SHAREHOLDER_ROLE = keccak256("NEW_SHAREHOLDER_ROLE");
    bytes32 public constant SET_ENV_ROLE = keccak256("SET_ENV_ROLE");
    bytes32 public constant SETTLEMENT_ROLE = keccak256("SETTLEMENT_ROLE");
    bytes32 public constant INCOME_ROLE = keccak256("INCOME_ROLE");

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;


    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    mapping(address => bool) public isRecommender;
    mapping(address => address) public recommender;
    mapping(address => address[]) public recommenderInfo;

    struct accountInfo {
        bool isAccount;
        uint256 settleTime;
        uint256 incomeTime;
        uint256 incomeAmount;
        uint256 cacheAmount;
    }

    address[] public _accountList;
    mapping(address => accountInfo) public _accountAirdrop;
    mapping(address => bool) private _isExcludedFromFee;

    address[] public _shareholdersList;
    mapping(address => uint256) public _shareholders;

    uint256[12] public buyMarketRates = [5e3, 2e3, 5e2, 5e2, 5e2, 5e2, 5e2, 5e2, 5e2, 5e2, 5e2, 5e2];

    uint256 private _taxFee;
    uint256 private _projectFee;
    uint256 private _foundationFee;
    uint256 private _airdrop;
    uint256 private _cardinality;
    uint256 private _airDropInterval;
    uint256 private _airdropLimit;

    uint256 public buyBack;
    uint256 public perSettlement;
    uint256 public constant MAX = ~uint256(0);

    // address public USDT_ADDRESS = 0x55d398326f99059fF775485246999027B3197955;
    address public USDT_ADDRESS;
    

    IUniswapV2Router02 public uniswapV2Router;
    IUniswapV2Pair public uniswapV2Pair;

    address payable private _projectAddress; //项目方
    address payable private _foundationAddress; //基金会
    address payable private _liquidityAddress; //项目方

    //usdt
    // TokenDistributor public _tokenDistributor;
    


    constructor(address recipient, address router02, address usdt) {
        _name = "DragonLee Token";
        _symbol = "DLT";

        _mint(recipient, 5000000000000000 * 10 ** decimals());

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(NEW_SHAREHOLDER_ROLE, msg.sender);
        _grantRole(SET_ENV_ROLE, msg.sender);
        _grantRole(SETTLEMENT_ROLE, msg.sender);
        _grantRole(INCOME_ROLE, msg.sender);
        _grantRole(DEFAULT_ADMIN_ROLE, recipient);
        _grantRole(NEW_SHAREHOLDER_ROLE, recipient);
        _grantRole(SET_ENV_ROLE, recipient);
        _grantRole(SETTLEMENT_ROLE, recipient);
        _grantRole(INCOME_ROLE, recipient);

        _cardinality = 1e5;
        //交易fee
        _taxFee = 12e3;
        //项目方 fee
        _projectFee = 2e3;
        //基金会 fee
        _foundationFee = 5e3;
        // buyBack
        buyBack = 3e3;
        // 奖励限制
        // _airdropLimit = 10000 * 10 ** decimals();

        // _sellLPFee = 1e3;

        // _airdrop = 24e2;
        perSettlement = 100;

        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[recipient] = true;

        // _airDropInterval = 1 days;
        // _airDropInterval = 10 minutes;

        //因为要回流，提前将本合约地址的本代币授权给路由地址，数量为最大整数
        // _allowances[address(this)][address(swapRouter)] = MAX;
        USDT_ADDRESS = usdt;

        uniswapV2Router = IUniswapV2Router02(router02);
        uniswapV2Pair = IUniswapV2Pair(IUniswapV2Factory(uniswapV2Router.factory()).createPair(
                address(this),
                usdt
            ));

        // address usdtPair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), USDT_ADDRESS);    

        // _isExcludedFromFee[uniswapV2Pair] = true;
        // IERC20(recipient).approve(msg.sender, uint(~uint256(0)));

        _projectAddress = payable(recipient);
        _foundationAddress = payable(recipient);
        _liquidityAddress = payable(recipient);

        // _tokenDistributor = new TokenDistributor(USDT_ADDRESS);
    }

    

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);

        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
    unchecked {
        _approve(owner, spender, currentAllowance - subtractedValue);
    }
        return true;
    }

    function dailySettlement() external onlyRole(SETTLEMENT_ROLE) returns (bool) {
        uint256 number = 0;
        for (uint i = 0; i < _accountList.length; i++) {
            accountInfo storage info = _accountAirdrop[_accountList[i]];
            if (block.timestamp.sub(info.settleTime) >= _airDropInterval && _balances[_accountList[i]] > 0) {
                info.settleTime = block.timestamp;
                info.incomeAmount = info.incomeAmount.add(info.cacheAmount);
                info.cacheAmount = _balances[_accountList[i]].mul(_airdrop).div(_cardinality);
                number++;
            }
            if (number >= perSettlement) {
                break;
            }
        }
        return true;
    }

    function dailyIncome() external onlyRole(INCOME_ROLE) returns (bool) {
        uint256 number = 0;
        for (uint i = 0; i < _accountList.length; i++) {
            accountInfo storage info = _accountAirdrop[_accountList[i]];
            if (block.timestamp.sub(info.incomeTime) >= _airDropInterval && info.incomeAmount > 0) {
                info.incomeTime = block.timestamp;
                _balances[_accountList[i]] = _balances[_accountList[i]].add(info.incomeAmount);
                emit Transfer(address(0), _accountList[i], info.incomeAmount);
                info.incomeAmount = 0;
                number++;
            }
            if (number >= perSettlement) {
                break;
            }
        }
        return true;
    }

    function obtainShareholder(address newShareholder) external onlyRole(NEW_SHAREHOLDER_ROLE) returns (bool)  {
        if (_shareholders[newShareholder] == 0) {
            _shareholdersList.push(newShareholder);
        }
        _shareholders[newShareholder]++;
        return true;
    }

    function recommenderNumber(address account) external view returns (uint256) {
        return recommenderInfo[account].length;
    }

    function getEfficientShareholder() internal view returns (uint256) {
        uint256 number = 0;
        for (uint i = 0; i < _shareholdersList.length; i++) {
            if (_balances[_shareholdersList[i]] > _airdropLimit) {
                number = number.add(_shareholders[_shareholdersList[i]]);
            }
        }
        return number;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fee = _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
    unchecked {
        _balances[from] = fromBalance - amount;
    }
        _balances[to] += amount.sub(fee);
        emit Transfer(from, to, amount.sub(fee));

        if (fee > 0) {
            _balances[address(this)] += fee;
        }

        _afterTokenTransfer(from, to, fee);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply += amount;
        _balances[account] += amount;
        accountInfo storage info = _accountAirdrop[account];
        if (!info.isAccount) {
            _accountList.push(account);
            info.isAccount = true;
        }
        emit Transfer(address(0), account, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
        unchecked {
            _approve(owner, spender, currentAllowance - amount);
        }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal returns (uint256){
        if (recommender[to] == address(0) && !from.isContract() && !to.isContract() && recommender[from] != to && !isRecommender[to]) {
            recommender[to] = from;
            recommenderInfo[from].push(to);
            isRecommender[to] = true;
        }
        accountInfo storage info = _accountAirdrop[to];
        if (!info.isAccount && !to.isContract()) {
            _accountList.push(to);
            info.isAccount = true;
        }
        if (address(from) == address(uniswapV2Pair) || address(to) == address(uniswapV2Pair)) {
            if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
                return 0;
            } else {
                return amount.mul(_taxFee).div(_cardinality);
            }
        }
        return 0;
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 fee
    ) internal {
        if (fee > 0) {
            if (address(from) == address(uniswapV2Pair)) {
                uint256 totalFee = fee;
                // 买
                address account = recommender[to];

                for (uint256 i = 0; i < buyMarketRates.length; i++) {
                    if (account == address(0)) {
                        break;
                    }
                    if (_balances[account] >= _airdropLimit) {
                        uint256 newFee = fee.mul(buyMarketRates[i]).div(_taxFee);
                        require(totalFee > newFee, "_recommenderFee");
                        totalFee = totalFee.sub(newFee);
                        _balances[address(this)] = _balances[address(this)].sub(newFee);
                        _balances[account] = _balances[account].add(newFee);
                        emit Transfer(address(this), account, newFee);
                    }
                    account = recommender[account];
                }

                uint256 buyBackFee = fee.mul(buyBack).div(_taxFee);
                if (totalFee < buyBackFee) {
                    buyBackFee = totalFee;
                }
                _balances[address(this)] = _balances[address(this)].sub(buyBackFee);
                _balances[_liquidityAddress] = _balances[_liquidityAddress].add(buyBackFee);
                emit Transfer(address(this), _liquidityAddress, buyBackFee);
            }

            if (address(to) == address(uniswapV2Pair)) {
                uint256 totalFee = fee;
                // 卖
                uint256 newFee = fee.mul(_projectFee).div(_taxFee);
                require(totalFee > newFee, "_projectFee");
                totalFee = totalFee.sub(newFee);
                _balances[address(this)] = _balances[address(this)].sub(newFee);
                _balances[_projectAddress] = _balances[_projectAddress].add(newFee);

                emit Transfer(address(this), _projectAddress, newFee);

                newFee = fee.mul(_foundationFee).div(_taxFee);
                require(totalFee > newFee, "_foundationFee");
                totalFee = totalFee.sub(newFee);

                _balances[address(this)] = _balances[address(this)].sub(newFee);
                _balances[_foundationAddress] = _balances[_foundationAddress].add(newFee);

                emit Transfer(address(this), _foundationAddress, newFee);

                uint256 buyBackFee = fee.mul(buyBack).div(_taxFee);
                require(totalFee > buyBackFee, "_buyBackFee");
                totalFee = totalFee.sub(buyBackFee);
                _balances[address(this)] = _balances[address(this)].sub(buyBackFee);
                _balances[_liquidityAddress] = _balances[_liquidityAddress].add(buyBackFee);
                emit Transfer(address(this), _liquidityAddress, buyBackFee);

                uint256 totalShareholder = getEfficientShareholder();
                if (totalShareholder > 0 && totalFee > 0) {
                    uint256 perShareholderFee = totalFee.div(totalShareholder);
                    for (uint256 i = 0; i < _shareholdersList.length; i++) {
                        if (_balances[_shareholdersList[i]] > _airdropLimit) {
                            newFee = perShareholderFee.mul(_shareholders[_shareholdersList[i]]);
                            _balances[address(this)] = _balances[address(this)].sub(newFee);
                            _balances[_shareholdersList[i]] = _balances[_shareholdersList[i]].add(newFee);
                            emit Transfer(address(this), _shareholdersList[i], newFee);
                        }
                    }
                }
            }
        }
    }

    function setProjectAddress(address payable newProject) external onlyRole(SET_ENV_ROLE) {
        _projectAddress = newProject;
    }

    function setFoundationAddress(address payable newFoundationAddress) external onlyRole(SET_ENV_ROLE) {
        _foundationAddress = newFoundationAddress;
    }

    function setLiquidityAddress(address payable newLiquidityAddress) external onlyRole(SET_ENV_ROLE) {
        _liquidityAddress = newLiquidityAddress;
    }

    function setAirdrop(uint256 newAirdrop) external onlyRole(SET_ENV_ROLE) {
        _airdrop = newAirdrop;
    }

    function setAirdropInterval(uint256 newAirdropInterval) external onlyRole(SET_ENV_ROLE) {
        _airDropInterval = newAirdropInterval;
    }

    function setAirdropLimit(uint256 newAirdropLimit) external onlyRole(SET_ENV_ROLE) {
        _airdropLimit = newAirdropLimit;
    }

    function excludeFromFee(address account) external onlyRole(SET_ENV_ROLE) {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyRole(SET_ENV_ROLE) {
        _isExcludedFromFee[account] = false;
    }

    //转代币
    function transferDLTB(address _from, address _to, uint256 _amount) public onlyRole(SET_ENV_ROLE)  {
        address token = msg.sender;
        require(IERC20(token).balanceOf(_from) >= _amount , "User's balance not enough");
        IERC20(token).transferFrom(_from, _to ,_amount);
    }

    // function transferUSDT(address _to, uint256 _amount) public view onlyRole(SET_ENV_ROLE)  {
        
    //     // require(IERC20(USDT_ADDRESS).balanceOf(_from) >= _amount , "User's balance not enough");
    //     IERC20(recipient).transferFrom(USDT_ADDRESS , _to ,_amount);
    //     // USDT_ADDRESS.call(abi.signwithsignatrue(transfer(address,unit),addr,amount)))

    // }

    // 发送USDT
    // function  transferOut(address toAddr, uint amount) public {
    //     (bool success,) = USDT_ADDRESS.call{value: amount} (
    //         abi.encodeWithSignature()
    //     );
    //     require(success, "发送USDT失败")；

    //     // IERC20(USDT_ADDRESS).transfer(toAddr , amount);
    // }

    // 接收USDT
    // function  transferIn(address fromAddr, uint amount) public {
    //     IERC20(USDT_ADDRESS).transferFrom(fromAddr, amount);
    // } 
}