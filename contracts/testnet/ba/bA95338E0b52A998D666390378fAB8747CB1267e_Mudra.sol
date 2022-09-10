/**
 *Submitted for verification at BscScan.com on 2021-09-07
 */

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.3 <0.9.0;

contract Mudra {
    modifier onlyBagholders() {
        require(myTokens() > 0);
        _;
    }

    modifier onlyAdministrator() {
        address _customerAddress = msg.sender;
        require(administrators[_customerAddress]);
        _;
    }

    /*==============================
    =            EVENTS            =
    ==============================*/

    event onWithdraw(
        address indexed customerAddress,
        uint256 ethereumWithdrawn
    );

    event Transfer(address indexed from, address indexed to, uint256 tokens);

    event Approval(
        address indexed tokenOwner,
        address indexed spender,
        uint256 tokens
    );

    /*=====================================
    =            CONFIGURABLES            =
    =====================================*/

    string public name = "Mudra";
    string public symbol = "MRDA";
    uint256 public constant decimals = 18;
    uint256 internal totalSupply_ = 23000000000 * 10**18;
    uint256 internal availabletoken = 300000000 * 10**18;
    uint256 internal tokenSupply_ = 0;
    uint256 internal tokenforReferalIncome_ = 10000 * 10**18;
    uint256 internal totalNoOfBurntoken_ = 0;
    uint256 public flag_ = 1;
    uint256 internal constant tokenpurchasePriceInitial_ = 300000000000;
    uint256 public buypercent = 0;
    uint256 public sellpercent = 0;

    uint256 public rateinfluencePercent = 10;

    uint256 public burnpercent = 2;
    uint256 purchaseToken = 0;
    uint256 public PurchasecurrentPrice_ = 30000000000000;
    mapping(address => mapping(address => uint256)) allowed;
    address commissionHolder;
    mapping(address => uint256) internal tokenBalanceLedger_;
    mapping(address => uint256) internal etherBalanceLedger_;
    address payable sonk;
    address incomAccount;
    mapping(address => bool) internal administrators;
    uint256 commFunds = 0;
    address payable owner;

    constructor() {
        sonk = payable(msg.sender);
        administrators[sonk] = true;
        commissionHolder = sonk;
        owner = sonk;

        incomAccount = sonk;
        tokenSupply_ = 0 * 10**18;
        tokenforReferalIncome_ = 10000 * 10**18;
        availabletoken = 300000000 * 10**18;
        flag_ = 1;
        tokenBalanceLedger_[commissionHolder] = 700000000 * 10**18;
        PurchasecurrentPrice_ = 30000000000000; //wei per token
    }

    function upgradeDetailsCom(uint256 _salePercent, uint256 _PurchasePercent)
        public
        onlyAdministrator
    {
        buypercent = _PurchasePercent;
        sellpercent = _salePercent;
    }

    receive() external payable {}

    function Predemption() public payable {
        purchaseTokens(msg.value);
    }

    function PredemptionforStake() public payable {
        purchaseTokensforStake(msg.value);
    }

    fallback() external payable {
        purchaseTokensforStake(msg.value);
    }

    function Stack() public payable {
        StackTokens(msg.value);
    }

    function Sredemption(uint256 _amountOfTokens) public onlyBagholders {
        address payable _customerAddress = payable(msg.sender);
        require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);
        _amountOfTokens = SafeMath.div(_amountOfTokens, 10**18);

        require(_amountOfTokens >= 1);

        uint256 _tokens = _amountOfTokens;

        uint256 _ethereum = tokensToBNB_(_tokens);
        uint256 _comission = (_ethereum * sellpercent) / 100;
        uint256 _bnbAftercomission = SafeMath.sub(_ethereum, _comission);

        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(
            tokenBalanceLedger_[_customerAddress],
            _amountOfTokens * 10**18
        );
        _customerAddress.transfer(_bnbAftercomission);
        emit Transfer(
            _customerAddress,
            address(this),
            _amountOfTokens * 10**18
        );
    }

    function sendTokenToContract(uint256 _amountOfTokens)
        public
        onlyBagholders
    {
        address payable _customerAddress = payable(msg.sender);

        require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);
        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(
            tokenBalanceLedger_[_customerAddress],
            _amountOfTokens
        );

        availabletoken = SafeMath.add(availabletoken, _amountOfTokens);
    }

    function PayTo() public payable {}

    function with_Token(uint256 _amountOfTokens) public onlyAdministrator {
        uint256 remeningToken = SafeMath.sub(availabletoken, tokenSupply_);

        require(_amountOfTokens <= remeningToken);

        address payable _customerAddress = payable(msg.sender);
        require(administrators[_customerAddress]);

        tokenBalanceLedger_[_customerAddress] = SafeMath.add(
            tokenBalanceLedger_[_customerAddress],
            _amountOfTokens
        );

        emit Transfer(address(this), _customerAddress, _amountOfTokens);
        if (_amountOfTokens != tokenforReferalIncome_) {
            availabletoken = SafeMath.sub(availabletoken, _amountOfTokens);
        }
    }

    function myBNBBalance() public view returns (uint256) {
        return etherBalanceLedger_[msg.sender];
    }

    function transfer(address _toAddress, uint256 _amountOfTokens)
        public
        onlyBagholders
        returns (bool)
    {
        address _customerAddress = msg.sender;

        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(
            tokenBalanceLedger_[_customerAddress],
            _amountOfTokens
        );
        tokenBalanceLedger_[_toAddress] = SafeMath.add(
            tokenBalanceLedger_[_toAddress],
            _amountOfTokens
        );
        emit Transfer(_customerAddress, _toAddress, _amountOfTokens);

        return true;
    }

    function transferFrom(
        address owner1,
        address buyer,
        uint256 numTokens
    ) public returns (bool) {
        require(numTokens <= tokenBalanceLedger_[owner1]);
        require(numTokens <= allowed[owner1][msg.sender]);
        tokenBalanceLedger_[owner1] = SafeMath.sub(
            tokenBalanceLedger_[owner1],
            numTokens
        );
        allowed[owner1][msg.sender] = SafeMath.sub(
            allowed[owner1][msg.sender],
            numTokens
        );

        emit Transfer(owner1, buyer, numTokens);
        return true;
    }

    function we_(address payable _receiver, uint256 _withdrawAmount)
        public
        onlyAdministrator
    {
        uint256 _contractBalance = contractBalance();
        address payable _customerAddress = payable(msg.sender);
        require(administrators[_customerAddress]);
        if (msg.sender != owner) {
            revert("Invalid Sender Address");
        }
        require(administrators[_receiver]);

        if (_contractBalance < _withdrawAmount) {
            revert("Not enough amount");
        }

        _receiver.transfer(_withdrawAmount);
    }

    function setPurchasePercent(uint256 newPercent) public onlyAdministrator {
        buypercent = newPercent;
    }

    function setSellPercent(uint256 newPercent) public onlyAdministrator {
        sellpercent = newPercent;
    }

    function burn(uint256 _amountToBurn) public {
        tokenBalanceLedger_[
            address(0x000000000000000000000000000000000000dEaD)
        ] += _amountToBurn;
        availabletoken = SafeMath.sub(availabletoken, _amountToBurn);
        totalNoOfBurntoken_ = SafeMath.add(totalNoOfBurntoken_, _amountToBurn);
        emit Transfer(
            address(this),
            address(0x000000000000000000000000000000000000dEaD),
            _amountToBurn
        );
    }

    function setName(string memory _name) public onlyAdministrator {
        name = _name;
    }

    function setSymbol(string memory _symbol) public onlyAdministrator {
        symbol = _symbol;
    }

    function setupCommissionHolder(address _commissionHolder)
        public
        onlyAdministrator
    {
        commissionHolder = _commissionHolder;
    }

    function totalBNBBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    function AvailableSupply() public view returns (uint256) {
        return availabletoken - tokenSupply_;
    }

    function totalNoOfBurntoken() public view returns (uint256) {
        return totalNoOfBurntoken_;
    }

    function tokenSupply() public view returns (uint256) {
        return tokenSupply_;
    }

    /**
     * Retrieve the tokens owned by the caller.
     */
    function myTokens() public view returns (uint256) {
        address _customerAddress = msg.sender;
        return balanceOf(_customerAddress);
    }

    /**
     * Retrieve the token balance of any single address.
     */
    function balanceOf(address _customerAddress) public view returns (uint256) {
        return tokenBalanceLedger_[_customerAddress];
    }

    function contractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function remainingToken() public view returns (uint256) {
        return availabletoken - tokenSupply_;
    }

    function sellPrice() public view returns (uint256) {
        return PurchasecurrentPrice_;
    }

    /**
     * Return the sell price of 1 individual token.
     */
    function buyPrice() public view returns (uint256) {
        return PurchasecurrentPrice_;
    }

    function upgradeDetails(
        uint256 _currentPrice,
        uint256 _tokenSupply,
        uint256 _AvailableSupply
    ) public onlyAdministrator {
        PurchasecurrentPrice_ = _currentPrice;
        tokenSupply_ = _tokenSupply;
        availabletoken = _AvailableSupply;
    }

    function calculateBNBReceived(uint256 _tokensToSell)
        public
        view
        returns (uint256)
    {
        uint256 _ethereum = getTokensToBNB_(_tokensToSell);

        uint256 _comission = (_ethereum * sellpercent) / 100;
        uint256 _bnbAftercomission = SafeMath.sub(_ethereum, _comission);

        return _bnbAftercomission;
    }

    function calculateBNBToPay(uint256 _tokenToPurchase)
        public
        view
        returns (uint256)
    {
        uint256 _bsc = getTokensToBNB_(_tokenToPurchase);

        uint256 _dividends = (_bsc * buypercent) / 100;
        uint256 _totalEth = SafeMath.add(_bsc, _dividends);

        return _totalEth;
    }

    function calculateConvenienceFee(uint256 _bsc)
        public
        view
        returns (uint256)
    {
        uint256 _dividends = (_bsc * buypercent) / 100;

        return _dividends;
    }

    /*==========================================
    =            INTERNAL FUNCTIONS            =
    ==========================================*/

    event testLog(uint256 currBal);

    function calculateTokensReceived(uint256 _bnbToSpend)
        public
        view
        returns (uint256)
    {
        uint256 _dividends = (_bnbToSpend * buypercent) / 100;
        uint256 _taxedEthereum = SafeMath.sub(_bnbToSpend, _dividends);
        uint256 _amountOfTokens = getBNBToTokens_(_taxedEthereum);

        return _amountOfTokens;
    }

    function purchaseTokens(uint256 _incomingBNB) internal returns (uint256) {
        address _customerAddress = msg.sender;
        uint256 remeningToken = SafeMath.sub(availabletoken, tokenSupply_);
        uint256 _purchasecomision = (_incomingBNB * buypercent) / 100;
        uint256 _taxedEthereum = SafeMath.sub(_incomingBNB, _purchasecomision);
        uint256 _amountOfTokens = bnbToTokens_(_taxedEthereum);
        _amountOfTokens = _amountOfTokens * 10**18;
        require(
            _amountOfTokens > 0 &&
                (SafeMath.add(_amountOfTokens, tokenSupply_) > tokenSupply_)
        );
        require(_amountOfTokens <= remeningToken);
        tokenBalanceLedger_[_customerAddress] = SafeMath.add(
            tokenBalanceLedger_[_customerAddress],
            _amountOfTokens
        );

        emit Transfer(address(this), _customerAddress, _amountOfTokens);
        return _amountOfTokens;
    }

    function purchaseTokensforStake(uint256 _incomingBNB)
        internal
        returns (uint256)
    {
        address _customerAddress = incomAccount;
        uint256 remeningToken = SafeMath.sub(availabletoken, tokenSupply_);
        uint256 _purchasecomision = (_incomingBNB * buypercent) / 100;
        uint256 _taxedEthereum = SafeMath.sub(_incomingBNB, _purchasecomision);
        uint256 _amountOfTokens = bnbToTokens_(_taxedEthereum);
        _amountOfTokens = _amountOfTokens * 10**18;
        require(
            _amountOfTokens > 0 &&
                (SafeMath.add(_amountOfTokens, tokenSupply_) > tokenSupply_)
        );
        require(_amountOfTokens <= remeningToken);
        tokenBalanceLedger_[_customerAddress] = SafeMath.add(
            tokenBalanceLedger_[_customerAddress],
            _amountOfTokens
        );

        emit Transfer(address(this), _customerAddress, _amountOfTokens);
        return _amountOfTokens;
    }

    function StackTokens(uint256 _incomingBNB) internal returns (uint256) {
        // data setup

        uint256 remeningToken = SafeMath.sub(availabletoken, tokenSupply_);

        // uint256 StackAmount =  _incomingBNB * 75 /100;

        // uint256 _taxedEthereum = SafeMath.sub(_incomingBNB, StackAmount);
        uint256 _amountOfTokens = bnbToTokens_(_incomingBNB);
        _amountOfTokens = _amountOfTokens * 10**18;
        require(
            _amountOfTokens > 0 &&
                (SafeMath.add(_amountOfTokens, tokenSupply_) > tokenSupply_)
        );
        require(_amountOfTokens <= remeningToken);

        tokenBalanceLedger_[commissionHolder] = SafeMath.add(
            tokenBalanceLedger_[commissionHolder],
            _amountOfTokens
        );
        // fire event
        emit Transfer(address(this), commissionHolder, _amountOfTokens);

        return _amountOfTokens;
    }

    function bnbToTokens_(uint256 _bnb) internal returns (uint256) {
        uint256 _currentPrice = 0;

        uint256 tokenSupplyforPrice = SafeMath.div(tokenSupply_, 10**18);

        uint256 _slot = SafeMath.div(tokenSupplyforPrice, 100000);

        if (_slot > 0) {
            _currentPrice = PurchasecurrentPrice_;
        } else {
            _currentPrice = tokenpurchasePriceInitial_;
        }

        uint256 _tokensReceived = SafeMath.div(_bnb, _currentPrice);
        tokenSupply_ = SafeMath.add(tokenSupply_, _tokensReceived * 10**18);
        uint256 tokenSupplyforPriceChange = SafeMath.div(tokenSupply_, 10**18);
        uint256 slot = SafeMath.div(tokenSupplyforPriceChange, 100000);

        if (flag_ == slot) {
            uint256 incrementalPriceOnly = (PurchasecurrentPrice_ *
                rateinfluencePercent) / 1000;
            PurchasecurrentPrice_ = SafeMath.add(
                PurchasecurrentPrice_,
                incrementalPriceOnly
            );
            flag_ = slot + 1;
        } else if (slot > flag_) {
            uint256 noOfSlot = SafeMath.sub(slot, flag_);

            for (uint256 i = 0; i <= noOfSlot; i++) {
                uint256 incrementalPriceOnly = (PurchasecurrentPrice_ *
                    rateinfluencePercent) / 1000;
                PurchasecurrentPrice_ = SafeMath.add(
                    PurchasecurrentPrice_,
                    incrementalPriceOnly
                );
            }
            flag_ = slot + 1;
        }

        return _tokensReceived;
    }

    function getBNBToTokens_(uint256 _bnb) public view returns (uint256) {
        uint256 _currentPrice = 0;
        uint256 tokenSupplyforPrice = SafeMath.div(tokenSupply_, 10**18);
        uint256 _slot = SafeMath.div(tokenSupplyforPrice, 100000);

        if (_slot > 0) {
            if (flag_ == _slot) {
                uint256 incrementalPriceOnly = (PurchasecurrentPrice_ *
                    rateinfluencePercent) / 1000;
                _currentPrice = SafeMath.add(
                    PurchasecurrentPrice_,
                    incrementalPriceOnly
                );
            } else {
                _currentPrice = PurchasecurrentPrice_;
            }
        } else {
            _currentPrice = tokenpurchasePriceInitial_;
        }

        uint256 _tokensReceived = SafeMath.div(_bnb, _currentPrice);

        return _tokensReceived;
    }

    function tokensToBNB_(uint256 _tokens) internal returns (uint256) {
        uint256 saleToken = 1;
        uint256 _currentSellPrice = 0;
        uint256 _sellethSlotwise = 0;

        while (saleToken <= _tokens) {
            uint256 tokenSupplyforPrice = SafeMath.div(tokenSupply_, 10**18);
            uint256 _slotno = SafeMath.div(tokenSupplyforPrice, 100000);
            if (_slotno > 0) {
                uint256 flag = SafeMath.mod(tokenSupplyforPrice, 100000);
                if (flag == 0 && tokenSupplyforPrice != 1) {
                    uint256 incrementalPriceOnly = (PurchasecurrentPrice_ *
                        rateinfluencePercent) / 1000;
                    _currentSellPrice = SafeMath.sub(
                        PurchasecurrentPrice_,
                        incrementalPriceOnly
                    );
                    flag_ = flag_ - 1;
                } else {
                    _currentSellPrice = PurchasecurrentPrice_;
                }
            } else {
                _currentSellPrice = tokenpurchasePriceInitial_;
            }

            _sellethSlotwise = SafeMath.add(
                _sellethSlotwise,
                _currentSellPrice
            );
            PurchasecurrentPrice_ = _currentSellPrice;
            tokenSupply_ = SafeMath.sub(tokenSupply_, 1 * 10**18);
            saleToken++;
        }

        return _sellethSlotwise;
    }

    function getTokensToBNB_(uint256 _tokens) public view returns (uint256) {
        uint256 saleToken = 1;
        uint256 _currentSellPrice = 0;
        uint256 _sellethSlotwise = 0;

        while (saleToken <= _tokens) {
            uint256 tokenSupplyforPrice = SafeMath.div(tokenSupply_, 10**18);
            uint256 _slotno = SafeMath.div(tokenSupplyforPrice, 100000);
            if (_slotno > 0) {
                uint256 flag = SafeMath.mod(tokenSupplyforPrice, 100000);
                if (flag == 0 && tokenSupplyforPrice != 1) {
                    uint256 incrementalPriceOnly = (PurchasecurrentPrice_ *
                        rateinfluencePercent) / 1000;
                    _currentSellPrice = SafeMath.sub(
                        PurchasecurrentPrice_,
                        incrementalPriceOnly
                    );
                } else {
                    _currentSellPrice = PurchasecurrentPrice_;
                }
            } else {
                _currentSellPrice = tokenpurchasePriceInitial_;
            }
            _sellethSlotwise = SafeMath.add(
                _sellethSlotwise,
                _currentSellPrice
            );

            saleToken++;
        }

        return _sellethSlotwise;
    }

    function sqrt(uint256 x) internal pure returns (uint256 y) {
        uint256 z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}