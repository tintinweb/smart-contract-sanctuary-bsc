// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BRealEstate is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    IERC20 BREToken;
    IERC20 USDB;
    address public breAddress;
    address public usdbAddress;
    struct Project {
        string symbol;
        uint256 lockedTime; //invest_duration
        uint256 startTime; //start ido
        uint256 endTime; //end ido
        uint256 expectedInterestRate; // = % * 100. Ex: 10% => 1000
        bool isSold;
        bool isDistributed;
        bool isRefunded;
        uint256[] offers;
        uint256 acceptOffer;
        uint256 totalClaimValue; //total reward value
        uint256 totalClaimed;
    }

    struct Stock {
        string symbol;
        uint256 circulatingSupply;
        uint256 totalSupply;
        uint256 burned; // burned when user claim reward
        uint256 idoPrice; //stock price
        uint256 minBuyIdo; //minimun stockIdo
        uint256 maxBuyIdo; //maximun stockIdo
        mapping(address => uint256) balances;
        uint256 holders;
        mapping(address => uint256) lockTransfers; //voted -> lock transfer until the lastest voted is expired
        uint256 idoWithdrew;
    }

    struct BuyerOffer {
        uint256 index;
        address buyer;
        string symbol;
        uint256 offerValue;
        mapping(address => VoteOption) voters;
        mapping(address => bool) isVoted;
        uint256 totalVoter;
        uint256 start; //vote starttime
        uint256 end; //vote endtime
        uint256 accepted;
        uint256 rejected;
        bool isCanceled;
    }

    enum VoteOption {
        Accepted,
        Rejected,
        CanceledVote
    }

    event CreateProject(
        string indexed _symbol,
        address owner,
        uint256 lockedTime,
        uint256 startTime, //start ido
        uint256 endTime,
        uint256 expectedInterestRate,
        uint256 circulatingSupply,
        uint256 totalSupply,
        uint256 idoPrice,
        uint256 minBuyIdo,
        uint256 maxBuyIdo,
        uint256 time
    );

    event DeleteProject(string indexed _symbol, address owner, uint256 time);

    event UpdateIdoInfo(
        string indexed _symbol,
        address owner,
        uint256 lockedTime,
        uint256 startTime, //start ido
        uint256 endTime,
        uint256 expectedInterestRate,
        uint256 time
    );

    event BuyIdo(
        string indexed _symbol,
        address owner,
        uint256 _amount,
        uint256 _tokenAmount,
        uint256 time
    );

    event AddBuyerOffer(
        uint256 offerIndex,
        address buyer,
        string symbol,
        uint256 offerValue,
        uint256 startTime,
        uint256 endTime,
        uint256 time
    );

    event ProjectSold(
        uint256 offerIndex,
        address buyer,
        string symbol,
        uint256 offerValue,
        uint256 time
    );

    event VoteAccepted(uint256 offerIndex, address voter, uint256 time);
    event VoteRejected(uint256 offerIndex, address voter, uint256 time);
    event CanceledVote(uint256 offerIndex, address voter, uint256 time);

    event CanceledOffer(
        uint256 offerIndex,
        address buyer,
        string symbol,
        uint256 offerValue,
        uint256 time
    );

    event DistributedProject(
        string symbol,
        uint256 totalClaimValue,
        bool isSold,
        uint256 time
    );

    event RefundedProject(string symbol, uint256 totalClaimValue, uint256 time);

    event ClaimReward(
        string symbol,
        uint256 stockAmount,
        uint256 amount,
        address claimer,
        uint256 time
    );

    event ClaimRefundIdo(
        string symbol,
        uint256 stockAmount,
        uint256 amount,
        address claimer,
        uint256 time
    );

    event ExchangeStock(
        string symbol,
        address buyer,
        address seller,
        uint256 stockAmount,
        uint256 tokenAmount,
        uint256 time
    );

    event ExchangeP2pStockFiat(
        string symbol,
        address buyer,
        address seller,
        uint256 stockAmount,
        uint256 fiatAmount,
        uint256 rateStockFiat,
        string fiatType,
        uint256 time
    );

    event WithdrawIdo(string symbol, address to, uint256 amount, uint256 time);

    uint256 private buyerOfferIndex;

    address private rewardsWallet;

    uint256 public totalProject;
    uint256 public totalInvestor;
    mapping(string => bool) private _projects;
    mapping(string => Project) public projects;
    mapping(string => bool) private _stocks;
    mapping(string => Stock) public stocks;
    // mapping(address => Investor) private investors;
    // mapping(address => bool) private _investors;

    mapping(address => bool) public admin;

    //use for exchangeStock and buyIdo: all users in system will be added when generated wallet (after kyc)
    mapping(address => bool) public whitelist;

    mapping(uint256 => BuyerOffer) public buyerOffers;

    mapping(string => bool) public fiatTypes;

    constructor(address _usdb, address _breToken) {
        buyerOfferIndex = 0;
        usdbAddress = _usdb;
        breAddress = _breToken;
        BREToken = IERC20(_breToken);
        USDB = IERC20(_usdb);
        fiatTypes["VND"] = true;
        fiatTypes["USD"] = true;
        admin[_msgSender()] = true;
        whitelist[_msgSender()] = true;
    }

    modifier isAdmin() {
        require(
            owner() == _msgSender() || admin[_msgSender()],
            "Adminable: caller is not the admin or owner"
        );
        _;
    }

    modifier isWhitelist() {
        require(
            owner() == _msgSender() || whitelist[_msgSender()],
            "Whitelistable: caller is not the admin, owner or whitelist"
        );
        _;
    }

    function updateStableCoin(address _usdb) external onlyOwner {
        usdbAddress = _usdb;
        USDB = IERC20(_usdb);
    }

    function updateBreToken(address _breToken) external onlyOwner {
        breAddress = _breToken;
        BREToken = IERC20(_breToken);
    }

    function addFiat(string calldata fiatType) external onlyOwner {
        fiatTypes[fiatType] = true;
    }

    function removeFiat(string calldata fiatType) external onlyOwner {
        require(!fiatTypes[fiatType], "Error: fiatType is existed");
        fiatTypes[fiatType] = false;
    }

    function createProject(
        string memory _symbol,
        uint256 _lockedTime,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _expectedInterestRate,
        uint256 _circulatingSupply,
        uint256 _totalSupply,
        uint256 _idoPrice,
        uint256 _minBuyIdo,
        uint256 _maxBuyIdo
    ) external isAdmin {
        require(!_projects[_symbol], "Error: project is exist");
        require(
            _startTime <= _endTime,
            "Error: _endTime must be later than _startTime"
        );
        require(
            _circulatingSupply <= _totalSupply,
            "Error: _totalSupply must be greater than _circulatingSupply"
        );

        require(
            _minBuyIdo <= _totalSupply,
            "Error: _minBuyIdo must be greater than _totalSupply"
        );

        require(
            _maxBuyIdo <= _totalSupply,
            "Error: _maxBuyIdo must be greater than _totalSupply"
        );

        require(
            _minBuyIdo <= _maxBuyIdo,
            "Error: _minBuyIdo must be greater than _maxBuyIdo"
        );

        //create stock
        Stock storage stock = stocks[_symbol];

        stock.symbol = _symbol;
        stock.circulatingSupply = _circulatingSupply;
        stock.totalSupply = _totalSupply;
        stock.idoPrice = _idoPrice;
        stock.minBuyIdo = _minBuyIdo;
        stock.maxBuyIdo = _maxBuyIdo;

        _stocks[_symbol] = true;

        //create project
        Project storage project = projects[_symbol];
        project.symbol = _symbol;
        project.lockedTime = _lockedTime;
        project.startTime = _startTime;
        project.endTime = _endTime;
        project.expectedInterestRate = _expectedInterestRate;
        project.isSold = false;

        _projects[_symbol] = true;

        totalProject += 1;

        emit CreateProject(
            _symbol,
            _msgSender(),
            _lockedTime,
            _startTime,
            _endTime,
            _expectedInterestRate,
            _circulatingSupply,
            _totalSupply,
            _idoPrice,
            _minBuyIdo,
            _maxBuyIdo,
            block.timestamp
        );
    }

    function deleteProject(string memory _symbol) external isAdmin {
        require(_projects[_symbol], "Error: project not exist");
        require(
            block.timestamp >= projects[_symbol].startTime,
            "Error: Time incorrect"
        );
        delete projects[_symbol];
        _projects[_symbol] = false;
        delete stocks[_symbol];
        _stocks[_symbol] = false;
        totalProject -= 1;
        emit DeleteProject(_symbol, _msgSender(), block.timestamp);
    }

    function updateIdoInfo(
        string memory _symbol,
        uint256 _lockedTime,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _expectedInterestRate
    ) external isAdmin {
        require(_projects[_symbol], "Error: project not exist");
        require(block.timestamp >= projects[_symbol].startTime);

        Project storage project = projects[_symbol];
        project.lockedTime = _lockedTime;
        project.startTime = _startTime;
        project.endTime = _endTime;
        project.expectedInterestRate = _expectedInterestRate;

        emit UpdateIdoInfo(
            _symbol,
            _msgSender(),
            _lockedTime,
            _startTime,
            _endTime,
            _expectedInterestRate,
            block.timestamp
        );
    }

    //ido
    function buyIdo(string memory _symbol, uint256 _amount)
        external
        payable
        isWhitelist
    {
        require(_projects[_symbol], "Error: project not exist");
        require(_stocks[_symbol], "Error: stock not exist");
        require(
            block.timestamp >= projects[_symbol].startTime,
            "Error: not start yet"
        );
        require(
            block.timestamp <= projects[_symbol].endTime,
            "Error: ido ended"
        );
        require(
            _amount <= stocks[_symbol].maxBuyIdo &&
                _amount >= stocks[_symbol].minBuyIdo,
            "Error: amount incorrect"
        );

        //TO DO: check
        require(
            USDB.balanceOf(_msgSender()) >= _amount,
            "Error: not enough USDB"
        );

        require(
            _amount <=
                stocks[_symbol].totalSupply - stocks[_symbol].circulatingSupply,
            "Error: Not enough stock balance"
        );

        //calculate stock
        uint256 tokenAmount = SafeMath.mul(_amount, stocks[_symbol].idoPrice);

        //payment
        USDB.safeTransferFrom(_msgSender(), address(this), tokenAmount);
        stocks[_symbol].circulatingSupply += _amount;
        if (stocks[_symbol].balances[_msgSender()] <= 0) {
            stocks[_symbol].holders += 1;
            totalInvestor += 1;
        }
        stocks[_symbol].balances[_msgSender()] += _amount;

        emit BuyIdo(
            _symbol,
            _msgSender(),
            _amount,
            tokenAmount,
            block.timestamp
        );
    }

    function addBuyerOffer(
        address _buyer,
        string memory _symbol,
        uint256 _offerValue,
        uint256 _startTime,
        uint256 _endTime
    ) external isAdmin {
        require(_projects[_symbol], "Error: project not exist");
        require(
            block.timestamp > projects[_symbol].endTime,
            "Error: Not the offer time yet"
        );
        require(!projects[_symbol].isSold, "Error: project was sold");
        require(
            _startTime < _endTime,
            "Error: endTime must be greater than startTime"
        );

        buyerOfferIndex += 1;
        //create buyer offer
        BuyerOffer storage buyerOffer = buyerOffers[buyerOfferIndex];
        buyerOffer.buyer = _buyer;
        buyerOffer.symbol = _symbol;
        buyerOffer.offerValue = _offerValue;
        buyerOffer.totalVoter = 0;
        buyerOffer.start = _startTime;
        buyerOffer.end = _endTime;
        buyerOffer.accepted = 0;
        buyerOffer.rejected = 0;

        //add to project
        projects[_symbol].offers.push(buyerOfferIndex);

        emit AddBuyerOffer(
            buyerOfferIndex,
            _buyer,
            _symbol,
            _offerValue,
            _startTime,
            _endTime,
            block.timestamp
        );
    }

    //>50% -> sell project
    function voteAcceptOffer(uint256 offerIndex) external {
        require(offerIndex <= buyerOfferIndex, "Error: Offer is not exist");

        BuyerOffer storage buyerOffer = buyerOffers[offerIndex];

        require(buyerOffer.isCanceled, "Error: offer is canceled");
        require(
            stocks[buyerOffer.symbol].balances[_msgSender()] > 0,
            "Error: No vote permission"
        );
        require(_projects[buyerOffer.symbol], "Error: project not exist");
        require(
            block.timestamp > projects[buyerOffer.symbol].endTime,
            "Error: Not the offer time yet"
        );
        require(!projects[buyerOffer.symbol].isSold, "Error: project was sold");
        require(!buyerOffer.isVoted[_msgSender()], "Error: voted before");

        require(
            block.timestamp >= buyerOffer.start &&
                block.timestamp <= buyerOffer.end,
            "Error: vote time incorrect"
        );

        buyerOffer.isVoted[_msgSender()] = true;
        buyerOffer.voters[_msgSender()] = VoteOption.Accepted;
        buyerOffer.accepted = SafeMath.add(
            stocks[buyerOffer.symbol].balances[_msgSender()],
            buyerOffer.accepted
        );
        if (
            stocks[buyerOffer.symbol].lockTransfers[_msgSender()] <
            buyerOffer.end
        ) {
            stocks[buyerOffer.symbol].lockTransfers[_msgSender()] = buyerOffer
                .end;
        }

        emit VoteAccepted(offerIndex, _msgSender(), block.timestamp);

        if (
            SafeMath.mul(buyerOffer.accepted, 2) >
            stocks[buyerOffer.symbol].totalSupply
        ) {
            projects[buyerOffer.symbol].isSold = true;
            projects[buyerOffer.symbol].acceptOffer = offerIndex;
            emit ProjectSold(
                offerIndex,
                buyerOffer.buyer,
                buyerOffer.symbol,
                buyerOffer.offerValue,
                block.timestamp
            );
        }
    }

    function voteRejectedOffer(uint256 offerIndex) external {
        require(offerIndex <= buyerOfferIndex, "Error: Offer is not exist");

        BuyerOffer storage buyerOffer = buyerOffers[offerIndex];

        require(buyerOffer.isCanceled, "Error: offer is canceled");
        require(
            stocks[buyerOffer.symbol].balances[_msgSender()] > 0,
            "Error: No vote permission"
        );
        require(_projects[buyerOffer.symbol], "Error: project not exist");
        require(
            block.timestamp > projects[buyerOffer.symbol].endTime,
            "Error: Not the offer time yet"
        );
        require(!projects[buyerOffer.symbol].isSold, "Error: project was sold");
        require(!buyerOffer.isVoted[_msgSender()], "Error: voted before");

        require(
            block.timestamp >= buyerOffer.start &&
                block.timestamp <= buyerOffer.end,
            "Error: vote time incorrect"
        );

        buyerOffer.isVoted[_msgSender()] = true;
        buyerOffer.voters[_msgSender()] = VoteOption.Rejected;
        buyerOffer.rejected = SafeMath.add(
            stocks[buyerOffer.symbol].balances[_msgSender()],
            buyerOffer.rejected
        );

        //lock transfer
        if (
            stocks[buyerOffer.symbol].lockTransfers[_msgSender()] <
            buyerOffer.end
        ) {
            stocks[buyerOffer.symbol].lockTransfers[_msgSender()] = buyerOffer
                .end;
        }

        emit VoteRejected(offerIndex, _msgSender(), block.timestamp);

        if (
            SafeMath.mul(buyerOffer.rejected, 2) >
            stocks[buyerOffer.symbol].totalSupply
        ) {
            buyerOffer.isCanceled = true;
            emit CanceledOffer(
                offerIndex,
                buyerOffer.buyer,
                buyerOffer.symbol,
                buyerOffer.offerValue,
                block.timestamp
            );
        }
    }

    function cancelVoteOffer(uint256 offerIndex) external {
        require(offerIndex <= buyerOfferIndex, "Error: Offer is not exist");

        BuyerOffer storage buyerOffer = buyerOffers[offerIndex];

        require(buyerOffer.isCanceled, "Error: offer is canceled");
        require(
            stocks[buyerOffer.symbol].balances[_msgSender()] > 0,
            "Error: No vote permission"
        );
        require(_projects[buyerOffer.symbol], "Error: project not exist");
        require(
            block.timestamp > projects[buyerOffer.symbol].endTime,
            "Error: Not the offer time yet"
        );
        require(!projects[buyerOffer.symbol].isSold, "Error: project was sold");
        require(buyerOffer.isVoted[_msgSender()], "Error: not vote");

        require(
            block.timestamp >= buyerOffer.start &&
                block.timestamp <= buyerOffer.end,
            "Error: vote time incorrect"
        );

        if (buyerOffer.voters[_msgSender()] == VoteOption.Rejected) {
            buyerOffer.rejected = SafeMath.sub(
                buyerOffer.rejected,
                stocks[buyerOffer.symbol].balances[_msgSender()]
            );
        } else {
            buyerOffer.accepted = SafeMath.sub(
                buyerOffer.accepted,
                stocks[buyerOffer.symbol].balances[_msgSender()]
            );
        }

        buyerOffer.isVoted[_msgSender()] = false;
        buyerOffer.voters[_msgSender()] = VoteOption.CanceledVote;

        //lock transfer
        if (
            stocks[buyerOffer.symbol].lockTransfers[_msgSender()] <
            buyerOffer.end
        ) {
            stocks[buyerOffer.symbol].lockTransfers[_msgSender()] = buyerOffer
                .end;
        }

        emit CanceledVote(offerIndex, _msgSender(), block.timestamp);
    }

    function cancelOffer(uint256 offerIndex) external {
        require(offerIndex <= buyerOfferIndex, "Error: Offer is not exist");

        BuyerOffer storage buyerOffer = buyerOffers[offerIndex];
        require(
            buyerOffer.buyer == _msgSender() || admin[_msgSender()],
            "Error: not owner of offer or admin "
        );
        require(!buyerOffer.isCanceled, "Error: offer is canceled");
        require(_projects[buyerOffer.symbol], "Error: project not exist");

        require(!projects[buyerOffer.symbol].isSold, "Error: project was sold");

        buyerOffer.isCanceled = true;
        emit CanceledOffer(
            offerIndex,
            buyerOffer.buyer,
            buyerOffer.symbol,
            buyerOffer.offerValue,
            block.timestamp
        );
    }

    //afer lockedTime or project sold
    function distributeProject(string memory _symbol, uint256 brePrice)
        external
        payable
        isAdmin
    {
        require(_projects[_symbol], "Error: Project not exist");
        require(
            !projects[_symbol].isDistributed,
            "Error: Project has been distributed"
        );
        require(
            projects[_symbol].isSold ||
                block.timestamp >
                SafeMath.add(
                    projects[_symbol].endTime,
                    projects[_symbol].lockedTime
                ),
            "Error: The project has not been sold and the lockedTime period has not expired"
        );

        require(projects[_symbol].acceptOffer > 0, "Error: Offer not exist");

        require(
            !projects[_symbol].isRefunded,
            "Error: Project has been refunded"
        );

        require(
            stocks[_symbol].circulatingSupply == stocks[_symbol].totalSupply,
            "Error: Project is not sold out. Must be refund"
        );

        //calculate reward
        uint256 totalRewardMax = SafeMath.mul(
            SafeMath.mul(
                stocks[_symbol].idoPrice,
                stocks[_symbol].circulatingSupply
            ),
            SafeMath.div(
                SafeMath.add(projects[_symbol].expectedInterestRate, 10000),
                10000
            )
        );
        uint256 totalReward;

        if (projects[_symbol].isSold) {
            if (
                buyerOffers[projects[_symbol].acceptOffer].offerValue >
                totalRewardMax
            ) {
                totalReward = totalRewardMax;
            } else {
                totalReward = buyerOffers[projects[_symbol].acceptOffer]
                    .offerValue;
            }
        } else {
            //end time -> enable refund
            totalReward = SafeMath.mul(
                stocks[_symbol].idoPrice,
                stocks[_symbol].circulatingSupply
            );
        }
        totalReward = SafeMath.mul(SafeMath.div(totalReward, brePrice), 10**18);

        require(
            BREToken.balanceOf(_msgSender()) >= totalReward,
            "Error: not enough BRE Token"
        );

        projects[_symbol].totalClaimValue = totalReward;

        projects[_symbol].totalClaimed = 0;
        //calculate reward
        BREToken.safeTransferFrom(
            _msgSender(),
            address(this),
            projects[_symbol].totalClaimValue
        );

        projects[_symbol].isDistributed = true;

        emit DistributedProject(
            _symbol,
            projects[_symbol].totalClaimValue,
            projects[_symbol].isSold,
            block.timestamp
        );
    }

    //ido failed
    function refundProject(string memory _symbol) external {
        require(_projects[_symbol], "Error: Project not exist");
        require(
            !projects[_symbol].isDistributed,
            "Error: Project has been distributed"
        );
        require(!projects[_symbol].isSold, "Error: Project has been sold out");

        require(
            block.timestamp > projects[_symbol].endTime &&
                stocks[_symbol].circulatingSupply !=
                stocks[_symbol].totalSupply,
            "Error: IDO is processing. Can't refund"
        );

        require(
            !projects[_symbol].isRefunded,
            "Error: Project has been refunded"
        );

        //end time -> enable refund
        projects[_symbol].totalClaimValue = SafeMath.mul(
            stocks[_symbol].idoPrice,
            stocks[_symbol].circulatingSupply
        );

        projects[_symbol].totalClaimed = 0;

        projects[_symbol].isRefunded = true;

        emit RefundedProject(
            _symbol,
            projects[_symbol].totalClaimValue,
            block.timestamp
        );
    }

    //for Project sold or out of lockedTime
    function claimReward(string calldata _symbol, uint256 _stockAmount)
        external
    {
        require(_projects[_symbol], "Error: project not exist");
        require(
            projects[_symbol].isDistributed || projects[_symbol].isRefunded,
            "Error: project is not distribute or refund"
        );
        if (_stockAmount == 0) {
            _stockAmount = stocks[_symbol].balances[_msgSender()];
        }
        require(
            stocks[_symbol].balances[_msgSender()] >= _stockAmount &&
                _stockAmount > 0,
            "Error: balance not enough"
        );

        stocks[_symbol].balances[_msgSender()] = SafeMath.sub(
            stocks[_symbol].balances[_msgSender()],
            _stockAmount
        );
        if (stocks[_symbol].balances[_msgSender()] <= 0) {
            stocks[_symbol].holders -= 1;
            totalInvestor -= 1;
        }
        uint256 tokenAmount = SafeMath.mul(
            SafeMath.div(_stockAmount, stocks[_symbol].totalSupply),
            projects[_symbol].totalClaimValue
        );
        projects[_symbol].totalClaimed = SafeMath.add(
            projects[_symbol].totalClaimed,
            tokenAmount
        );
        if (projects[_symbol].isDistributed) {
            BREToken.safeTransfer(_msgSender(), tokenAmount);
            emit ClaimReward(
                _symbol,
                _stockAmount,
                tokenAmount,
                _msgSender(),
                block.timestamp
            );
        } else {
            USDB.safeTransfer(_msgSender(), tokenAmount);
            emit ClaimRefundIdo(
                _symbol,
                _stockAmount,
                tokenAmount,
                _msgSender(),
                block.timestamp
            );
        }
    }

    function getClaimInfo(string memory _symbol, address _user)
        external
        view
        returns (
            uint8 claimType, //0: null, 1: distribute, 2: refund
            string memory symbol,
            address user,
            uint256 amountStock,
            address currency
        )
    {
        require(_projects[_symbol], "Error: project not exist");
        amountStock = stocks[_symbol].balances[_user];
        if (projects[_symbol].isDistributed) {
            currency = breAddress;
            claimType = 1;
        } else if (projects[_symbol].isRefunded) {
            
            currency = breAddress;
            claimType = 2;
        } else {
            claimType = 0;
        }
        user = _user;
        symbol = _symbol;
    }

    //call from buyer
    // function exchangeStock(
    //     string calldata _symbol,
    //     address _seller,
    //     uint256 _stockAmount,
    //     uint256 _tokenAmount
    // ) external payable isWhitelist {
    //     require(_projects[_symbol], "Error: project not exist");
    //     require(
    //         stocks[_symbol].balances[_seller] >= _stockAmount,
    //         "Error: balance of seller is not enough"
    //     );
    //     require(
    //         BREToken.balanceOf(_msgSender()) >= _tokenAmount,
    //         "Error: not enough BREToken"
    //     );
    //     require(
    //         block.timestamp > projects[_symbol].startTime,
    //         "Error: ido is processing, can't exchange"
    //     );

    //     require(
    //         stocks[_symbol].lockTransfers[_seller] < block.timestamp ||
    //             projects[_symbol].isSold,
    //         "Error: Can't transfer. Your stocks was locked"
    //     );

    //     BREToken.safeTransfer(_seller, _tokenAmount);

    //     stocks[_symbol].balances[_seller] = SafeMath.sub(
    //         stocks[_symbol].balances[_seller],
    //         _stockAmount
    //     );

    //     if (stocks[_symbol].balances[_seller] <= 0) {
    //         stocks[_symbol].holders -= 1;
    //         totalInvestor -= 1;
    //     }

    //     if (stocks[_symbol].balances[_msgSender()] <= 0) {
    //         stocks[_symbol].holders += 1;
    //         totalInvestor += 1;
    //     }

    //     stocks[_symbol].balances[_msgSender()] = SafeMath.add(
    //         stocks[_symbol].balances[_msgSender()],
    //         _stockAmount
    //     );

    //     emit ExchangeStock(
    //         _symbol,
    //         _msgSender(),
    //         _seller,
    //         _stockAmount,
    //         _tokenAmount,
    //         block.timestamp
    //     );
    // }

    function exchangeP2pStockFiat(
        string calldata _symbol,
        address _buyer,
        address _seller,
        uint256 _stockAmount,
        uint256 _fiatAmount,
        uint256 _rateStockFiat,
        string calldata fiatType
    ) external isAdmin {
        require(_projects[_symbol], "Error: project not exist");
        require(fiatTypes[fiatType], "Error: FiatType not exist");
        require(
            stocks[_symbol].balances[_seller] >= _stockAmount,
            "Error: balance of seller is not enough"
        );
        require(
            block.timestamp > projects[_symbol].startTime,
            "Error: ido is processing, can't exchange"
        );

        require(
            stocks[_symbol].lockTransfers[_seller] < block.timestamp ||
                projects[_symbol].isSold,
            "Error: Can't transfer. Your stocks was locked"
        );

        stocks[_symbol].balances[_seller] = SafeMath.sub(
            stocks[_symbol].balances[_seller],
            _stockAmount
        );

        if (stocks[_symbol].balances[_seller] <= 0) {
            stocks[_symbol].holders -= 1;
            totalInvestor -= 1;
        }

        if (stocks[_symbol].balances[_buyer] <= 0) {
            stocks[_symbol].holders += 1;
            totalInvestor += 1;
        }

        stocks[_symbol].balances[_buyer] = SafeMath.add(
            stocks[_symbol].balances[_buyer],
            _stockAmount
        );

        emit ExchangeP2pStockFiat(
            _symbol,
            _buyer,
            _seller,
            _stockAmount,
            _fiatAmount,
            _rateStockFiat,
            fiatType,
            block.timestamp
        );
    }

    function withdrawIdo(string calldata _symbol) external isAdmin {
        require(_projects[_symbol], "Error: Project not exist");
        require(
            block.timestamp > projects[_symbol].endTime,
            "Error: Ido is processing"
        );

        require(
            stocks[_symbol].circulatingSupply == stocks[_symbol].totalSupply,
            "Error: Project is not sold out. Must be refund"
        );

        require(stocks[_symbol].idoWithdrew == 0, "Error: IDO withdrew");

        uint256 totalUsdb = SafeMath.mul(
            stocks[_symbol].idoPrice,
            stocks[_symbol].circulatingSupply
        );
        USDB.safeTransfer(_msgSender(), totalUsdb);

        stocks[_symbol].idoWithdrew = totalUsdb;

        emit WithdrawIdo(_symbol, _msgSender(), totalUsdb, block.timestamp);
    }

    function addAdmin(address[] memory addrs) external onlyOwner {
        for (uint256 i = 0; i < addrs.length; i++) {
            admin[addrs[i]] = true;
        }
    }

    function removeAdmin(address[] memory addrs) external onlyOwner {
        for (uint256 i = 0; i < addrs.length; i++) {
            admin[addrs[i]] = false;
        }
    }

    function addWhitelist(address[] memory addrs) external {
        require(
            admin[_msgSender()] || _msgSender() == owner(),
            "Error: not admin"
        );
        for (uint256 i = 0; i < addrs.length; i++) {
            whitelist[addrs[i]] = true;
        }
    }

    function removeWhitelist(address[] memory addrs) external {
        require(
            admin[_msgSender()] || _msgSender() == owner(),
            "Error: not admin"
        );
        for (uint256 i = 0; i < addrs.length; i++) {
            whitelist[addrs[i]] = false;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
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

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
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

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
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

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}