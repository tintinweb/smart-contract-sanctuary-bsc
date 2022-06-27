/**
 *Submitted for verification at BscScan.com on 2022-06-27
*/

// SPDX-License-Identifier: SimPL-2.0
pragma solidity ^0.8.0;

interface Token {
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function approve(address spender, uint256 amount) external returns (bool);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function contractBonus(
        address[] calldata _address,
        uint256[] calldata _amount
    ) external returns (bool);

    function additional(uint256 profit_amount, address push_address)
        external
        returns (bool);

    function additionalCoin(uint256 profit_amount, address push_address)
        external
        returns (bool);
}

contract BTX {
    address public founder = address(0);
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) public _allowances;
    mapping(address => address) private leader;
    mapping(address => address[]) private directPush;
    mapping(address => uint256) private subordinate;
    uint256 public totalSupply;
    string public name;
    string public symbol;
    uint8 public decimals = 11;
    mapping(address => bool) public buyAddress;
    mapping(address => bool) public sellAddress;
    uint8 public buySlipPoint = 10;
    uint8 public sellSlipPoint = 10;
    address public pairAddress;
    address private usdtAddress = 0xf7263876C5d6543e5D2EAcAf76797aA4D5d874f4;
    uint8 private usdtDecimals = 18;
    address public pancakeAddress = 0xf7263876C5d6543e5D2EAcAf76797aA4D5d874f4;
    address public BTXcAddress;
    uint256 public destroyNum;
    uint256 public BTXUsdt;
    address public usdtFoundationAddress;
    address public BTXFoundationAddress;
    uint256 public todayBonusNum;
    mapping(address => bool) public whiteList;
    uint256 public totalDestruction = 10500 * 10**decimals;
    uint256 public endDestruction = 5100 * 10**decimals;
    mapping(address => bool) private mobilityMappingAddress;
    address[] private mobilityArrayAddress;
    uint8 public serviceCharge = 2;
    uint256 public BTXMax = 20 * 10**decimals;
    uint8 public transferMaxRatio = 90;
    mapping(address => uint256) airdropQuantity;
    address public additionalAddress;
    address public BTXCoinAddress;
    address public usdtCoinAddress;
    address public BTXcAdditionalAddress;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 totalSupply_
    ) {
        founder = msg.sender;
        name = name_;
        symbol = symbol_;
        _mint(address(this), totalSupply_ * 10**decimals);
    }

    function approveContract(
        address _address,
        address spender,
        uint256 amount
    ) external returns (bool) {
        require(msg.sender == founder);
        Token token = Token(_address);
        token.approve(spender, amount);
        return true;
    }

    function transferContract(
        address _address,
        address spender,
        uint256 amount
    ) external returns (bool) {
        require(msg.sender == founder);
        Token token = Token(_address);
        token.transfer(spender, amount);
        return true;
    }

    function setAdditionalAddress(address _address) public returns (bool) {
        require(msg.sender == founder);
        additionalAddress = _address;
        return true;
    }

    function setBTXCoinAddress(address _address) public returns (bool) {
        require(msg.sender == founder);
        BTXCoinAddress = _address;
        return true;
    }

    function setUsdtCoinAddress(address _address) public returns (bool) {
        require(msg.sender == founder);
        usdtCoinAddress = _address;
        return true;
    }

    function setBTXcAdditionalAddress(address _address) public returns (bool) {
        require(msg.sender == founder);
        BTXcAdditionalAddress = _address;
        return true;
    }

    function setFounder(address _address) public returns (bool) {
        require(msg.sender == founder);
        founder = _address;
        return true;
    }

    function setBuyAddress(address _address) public returns (bool) {
        require(msg.sender == founder);
        buyAddress[_address] = true;
        return true;
    }

    function removeBuyAddress(address _address) public returns (bool) {
        require(msg.sender == founder);
        buyAddress[_address] = false;
        return true;
    }

    function setSellAddress(address _address) public returns (bool) {
        require(msg.sender == founder);
        sellAddress[_address] = true;
        return true;
    }

    function removeSellAddress(address _address) public returns (bool) {
        require(msg.sender == founder);
        sellAddress[_address] = false;
        return true;
    }

    function setBuySlipPoint(uint8 _number) public returns (bool) {
        require(msg.sender == founder);
        buySlipPoint = _number;
        return true;
    }

    function setSellSlipPoint(uint8 _number) public returns (bool) {
        require(msg.sender == founder);
        sellSlipPoint = _number;
        return true;
    }

    function setPairAddress(address _address) public returns (bool) {
        require(msg.sender == founder);
        pairAddress = _address;
        return true;
    }

    function setPancakeAddress(address _address) public returns (bool) {
        require(msg.sender == founder);
        pancakeAddress = _address;
        return true;
    }

    function setBTXcAddress(address _address) public returns (bool) {
        require(msg.sender == founder);
        BTXcAddress = _address;
        return true;
    }

    function setTodayBonusNum(uint256 _number) public returns (bool) {
        require(msg.sender == founder);
        todayBonusNum = _number;
        return true;
    }

    function addTodayBonusNum(uint256 _number) public returns (bool) {
        require(msg.sender == additionalAddress);
        todayBonusNum += _number;
        return true;
    }

    function profitCoin(address _address, uint256 _number)
        public
        returns (bool)
    {
        require(msg.sender == additionalAddress);
        _balances[_address] += _number;
        emit Transfer(address(this), _address, _number);
        return true;
    }

    function setBTXUsdt(uint256 _number) public returns (bool) {
        require(msg.sender == founder);
        BTXUsdt = _number;
        return true;
    }

    function setUsdtFoundationAddress(address _address) public returns (bool) {
        require(msg.sender == founder);
        usdtFoundationAddress = _address;
        return true;
    }

    function setBTXFoundationAddress(address _address) public returns (bool) {
        require(msg.sender == founder);
        BTXFoundationAddress = _address;
        return true;
    }

    function setWhiteLists(address[] memory _address) public returns (bool) {
        require(msg.sender == founder);
        for (uint256 i = 0; i < _address.length; i++) {
            whiteList[_address[i]] = true;
        }
        return true;
    }

    function removeWhiteLists(address[] memory _address) public returns (bool) {
        require(msg.sender == founder);
        for (uint256 i = 0; i < _address.length; i++) {
            whiteList[_address[i]] = false;
        }
        return true;
    }

    function setTotalDestruction(uint256 _number) public returns (bool) {
        require(msg.sender == founder);
        totalDestruction = _number * 10**decimals;
        return true;
    }

    function setEndDestruction(uint256 _number) public returns (bool) {
        require(msg.sender == founder);
        endDestruction = _number * 10**decimals;
        return true;
    }

    function getMobilityArrayAddressLength() public view returns (uint256) {
        return mobilityArrayAddress.length;
    }

    function getMobilityArrayAddress(uint256 i) public view returns (address) {
        return mobilityArrayAddress[i];
    }

    function setServiceCharge(uint8 _number) public returns (bool) {
        require(msg.sender == founder);
        serviceCharge = _number;
        return true;
    }

    function setBTXMax(uint256 _number) public returns (bool) {
        require(msg.sender == founder);
        BTXMax = _number * 10**decimals;
        return true;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function contractAirdrop(address recipient, uint256 amount)
        public
        returns (bool)
    {
        require(msg.sender == founder);
        whiteList[recipient] = true;
        uint256 senderBalance = _balances[address(this)];
        require(
            senderBalance >= amount,
            "BEP20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[address(this)] = senderBalance - amount;
        }
        _balances[recipient] += amount;
        whiteList[recipient] = true;
        emit Transfer(address(this), recipient, amount);
        return true;
    }

    function contractTransfer(address recipient, uint256 amount)
        public
        returns (bool)
    {
        require(msg.sender == founder);
        uint256 senderBalance = _balances[address(this)];
        require(
            senderBalance >= amount,
            "BEP20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[address(this)] = senderBalance - amount;
        }
        _balances[recipient] += amount;
        emit Transfer(address(this), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(
            currentAllowance >= amount,
            "BEP20: transfer amount exceeds allowance"
        );
        unchecked {
            _approve(sender, msg.sender, currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        returns (bool)
    {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(
            currentAllowance >= subtractedValue,
            "BEP20: decreased allowance below zero"
        );
        unchecked {
            _approve(msg.sender, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function get_direct_push(address account)
        public
        view
        returns (address[] memory)
    {
        return directPush[account];
    }

    function get_leader(address account) public view returns (address) {
        return _leader(account);
    }

    function get_subordinate(address account) public view returns (uint256) {
        return _subordinate(account);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "BEP20: transfer amount exceeds balance"
        );

        require(amount >= 100, "BEP20: error");

        if (!whiteList[sender]) {
            uint256 now_balance = _balances[sender];
            if (amount > (now_balance * transferMaxRatio) / 100) {
                require(false, "BEP20: sender too many transactions");
            }
        }

        uint256 amounts = amount;

        uint256 profit_amount = 0;
        address push_address;
        if (totalDestruction - endDestruction > destroyNum) {
            if (buyAddress[sender]) {
                if (!whiteList[recipient]) {
                    uint256 usdtMobilityNum = Token(usdtAddress).balanceOf(
                        pairAddress
                    );
                    uint8 slip_point = buySlipPoint;
                    if (usdtMobilityNum >= 500 * 10**22) {
                        slip_point = 5;
                    } else if (usdtMobilityNum >= 200 * 10**22) {
                        slip_point = 7;
                    } else if (usdtMobilityNum >= 100 * 10**22) {
                        slip_point = 8;
                    } else if (usdtMobilityNum >= 50 * 10**22) {
                        slip_point = 9;
                    }
                    profit_amount = (amount * slip_point) / 100;
                    amounts = amount - profit_amount;
                    push_address = recipient;

                    totalSupply -= profit_amount;
                    destroyNum += profit_amount;
                    _balances[additionalAddress] += profit_amount;
                    Token(additionalAddress).additionalCoin(
                        profit_amount,
                        push_address
                    );
                }
            } else if (sellAddress[recipient]) {
                if (!mobilityMappingAddress[sender]) {
                    mobilityArrayAddress.push(sender);
                    mobilityMappingAddress[sender] = true;
                }
                if (!whiteList[sender]) {
                    uint256 usdtMobilityNums = Token(usdtAddress).balanceOf(
                        pairAddress
                    );
                    uint256 BTXMobilityNums = balanceOf(pairAddress);
                    uint256 BTXNowUsdt = (usdtMobilityNums * 100 * 10**11) /
                        BTXMobilityNums /
                        10**18;
                    uint8 slip_point = sellSlipPoint;
                    if (BTXNowUsdt < BTXUsdt) {
                        uint256 difference = BTXUsdt - BTXNowUsdt;
                        uint256 ratio = (100 * difference) / BTXUsdt;
                        if (ratio > 15) {
                            slip_point = 30;
                        } else if (ratio > 10) {
                            slip_point = 25;
                        } else if (ratio > 5) {
                            slip_point = 20;
                        } else if (ratio > 0) {
                            slip_point = 15;
                        }
                    }
                    profit_amount = (amount * slip_point) / 100;
                    amounts = amount - profit_amount;
                    push_address = sender;

                    totalSupply -= profit_amount;
                    destroyNum += profit_amount;
                    _balances[additionalAddress] += profit_amount;
                    Token(additionalAddress).additional(
                        profit_amount,
                        push_address
                    );
                }
            } else {
                if (!whiteList[sender]) {
                    uint256 foundation_amount = (amount * serviceCharge) / 100;
                    _balances[BTXFoundationAddress] += foundation_amount;
                    senderBalance = senderBalance - foundation_amount;
                    _balances[sender] = senderBalance;
                }
            }
        }

        if (!whiteList[recipient]) {
            uint256 now_balance = _balances[recipient];
            if (now_balance + amounts > BTXMax) {
                require(false, "BEP20: recipient too many transactions");
            }
        }

        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amounts;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "BEP20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal returns (bool) {
        if (
            _leader(to) == address(0) &&
            amount >= 1 &&
            from != to &&
            from != address(this) &&
            to != address(this)
        ) {
            if (!buyAddress[from] && !sellAddress[to]) {
                bool verify_leader_valid = _verify_leader_valid(to, from);
                if (verify_leader_valid) {
                    directPush[from].push(to);
                    leader[to] = from;
                    subordinate[from] += 1;
                }
            }
        }
        return true;
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal {}

    function _leader(address account) internal view returns (address) {
        return leader[account];
    }

    function _subordinate(address account) internal view returns (uint256) {
        return subordinate[account];
    }

    function _verify_leader_valid(address from, address to)
        internal
        view
        returns (bool)
    {
        address to_leader = _leader(to);
        if (to_leader == address(0)) {
            return true;
        }
        if (to_leader == from) {
            return false;
        }
        return _verify_leader_valid(from, to_leader);
    }

    function BTXcBurn(address account, uint256 amount) public returns (bool) {
        require(msg.sender == BTXcAdditionalAddress);
        _burn(account, amount);
        return true;
    }

    function contractBonus(
        address[] calldata _address,
        uint256[] calldata _amount
    ) public returns (bool) {
        require(msg.sender == founder);
        require(_address.length == _amount.length);
        for (uint256 i = 0; i < _address.length; i++) {
            if (mobilityMappingAddress[_address[i]]) {
                airdropQuantity[_address[i]] += _amount[i];
                _balances[_address[i]] += _amount[i];
                emit Transfer(address(this), _address[i], _amount[i]);
            }
        }
        Token(BTXcAddress).contractBonus(_address, _amount);
        return true;
    }
}