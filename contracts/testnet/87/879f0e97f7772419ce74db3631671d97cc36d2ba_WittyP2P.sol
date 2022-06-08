/**
 *Submitted for verification at BscScan.com on 2022-06-08
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract WittyP2P {
    
    //using SafeMath for uint256;
    struct proposals{
        uint buyerUserCount;
        bool postStatus;
        uint types;
        uint favour;
        address given;
        address expectAddr;
        uint256 totalAmt;
    }
    
    struct tradingDetails {
        uint count;
        uint buyerAmt;
    }
    
    struct userDetails {
        address[] referer;
        uint totalRefererCommission;
    }
    
    address public owner;
    uint public postId;
    bool public lockStatus;
    uint[10] public refPercent = [15,5,5,5,5,5,5,5,5,5];         // [12,8,5];
    uint public buyerFee = 1e18;                              // 0.5e18;
    uint public wittyDiscount = 0.25e18;
    uint8 public tokenLength;
    address public token;
    
    mapping(uint => proposals)public trade;
    mapping(uint => bool)public cancelStatus;
    mapping(uint => uint)public tradeCount;
    mapping(address => mapping(uint => tradingDetails))public traderList;
    mapping(address => uint[])public traderTrades;
    mapping(address => userDetails) public users;
    mapping(uint => address)public tokenList;
    mapping(address => uint)public wittyBalance;
    mapping(address => uint)public adminRevenue;
    mapping(address => mapping(address => uint))public refererCommission;

    event Post(address indexed from,uint post,uint Type,uint favour,uint amt,address expect,address token,uint time);
    event Exchange(address indexed from,uint tradeid,uint tradecount,address sell,uint sellAmount, uint buyAmount, uint time);
    event SellerTransfer(address indexed from,uint tradeid,uint tradeidcount,uint amt,uint time);
    event BuyerTransfer(address indexed from,uint tradeid,uint tradeidcount,uint amt,uint time);
    event SellerCancel(address indexed from,uint tradeid,uint tradeidcount,uint amt, bool status,uint time);
    event SellerActivate(address indexed from,uint tradeid,bool status,uint time);
    event Deposit(address indexed from,address indexed to,address token,uint amt,uint time);
    
    constructor (address _owner,address _witty)  {
        owner = _owner;
        token = _witty;
    }
    
     /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Only Owner");
        _;
    }
    
    /**
     * @dev Throws if lockStatus is true
     */
    modifier isLock() {
        require(lockStatus == false, "Contract Locked");
        _;
    }
    
    modifier Trade(uint _tradeID) {
        require(_tradeID <= postId && _tradeID > 0,"Invalid trade id");
         _;
    }
    
    receive()payable external {}

    function depositWitty(uint amount)public {
        require(amount > 0,"Invalid params");
        IERC20(token).transferFrom(msg.sender,address(this),amount);
        wittyBalance[msg.sender] += amount;
    }
    
    // Admin can create trade
    function createPost(uint _type,uint _amount,address _given,uint _expectID,uint _favour) public onlyOwner isLock payable onlyOwner {
        require (_type == 1 || _type == 2,"Incorrect type");
        require (_favour == 1 || _favour == 2,"Incorrect favour");
        require (_expectID <= tokenLength && _expectID > 0,"Invalid Expect id");
        require(tokenList[_expectID] != address(0),"Expect address not found");
        require(tokenList[_expectID] != _given,"Expect given not to be same");
        
        postId++;
        proposals storage _Trade = trade[postId];
        
        if (_type == 1) {
            require(_given == address(this), "Token addr should be 0");
            require(_amount == 0 && msg.value > 0, "Invalid amount");

            payable(_given).transfer(msg.value);
            _Trade.given = _given;
            _Trade.postStatus = true;
            _Trade.types = _type;
            _Trade.favour = _favour;
            _Trade.totalAmt =  msg.value;
            _Trade.expectAddr = tokenList[_expectID];

            emit Post(msg.sender, postId, _type, _favour, msg.value, tokenList[_expectID], _given, block.timestamp);
        }
        
        else if (_type == 2) {
            
            require(_given != address(0),"Need token addr");
            require(msg.value == 0 && _amount > 0,"Invalid amount");
            
            IERC20(_given).transferFrom(msg.sender, address(this), _amount);
            _Trade.given = _given;
            _Trade.postStatus = true;
            _Trade.types = _type;
            _Trade.favour = _favour;
            _Trade.totalAmt =  _amount;
            _Trade.expectAddr = tokenList[_expectID];

            emit Post(msg.sender, postId, _type, _favour, _amount, tokenList[_expectID], _given, block.timestamp);
        }
    }
    
    // Buyers can exchange here by given tradeid and amount
    function exchange(uint _tradeID, address _sell, uint _sellAmount, uint _buyAmount, address[] memory _ref, uint8 buychoice) public isLock Trade(_tradeID)  payable {
        
        proposals storage _Trade = trade[_tradeID];
        require(msg.sender != owner, "Seller can't exchange");
        require(cancelStatus[_tradeID] == false, "Seller cancel the trade");
        require(refPercent.length == _ref.length, "Incorrect referer values");
        require(_Trade.expectAddr == _sell, "This is not expect addr");
        require(_Trade.totalAmt >= _buyAmount, "Not enough amount left");

        if (_Trade.favour == 1) {
            require(msg.value > 0 && _sellAmount == 0, "Incorrect value");
            require(payable(address(this)).send(msg.value), "Favour 1 failed");
            // traderList[msg.sender][_tradeID].buyerAmt += msg.value;

            // uint256 _sellFee = msg.value * buyerFee/100e18;
            // uint256 _sellAmt = msg.value - _sellFee;

            if (_Trade.expectAddr == token) { buychoice = 0; }
            
            buyerTransfer(_tradeID, msg.sender, msg.value, tradeCount[_tradeID], buychoice, _ref);
            
        }
        else if (_Trade.favour == 2) {
            require(_sellAmount > 0 && msg.value == 0, "Incorrect value");
            require(IERC20(_sell).transferFrom(msg.sender, address(this), _sellAmount), "Favour 2 failed");
            // traderList[msg.sender][_tradeID].buyerAmt += _sellAmount;
                
            // uint256 _sellFee = _sellAmount * buyerFee/100e18;
            // uint256 _sellAmt = _sellAmount - _sellFee;

            if (_Trade.expectAddr == token) { buychoice = 0; }

            buyerTransfer(_tradeID, msg.sender, _sellAmount, tradeCount[_tradeID], buychoice, _ref);
        }

        if(_Trade.types == 1) {
            
            payable(msg.sender).transfer(_buyAmount);
            emit SellerTransfer(owner, _tradeID, tradeCount[_tradeID], _buyAmount, block.timestamp);
            _Trade.totalAmt =  _Trade.totalAmt - _buyAmount;
    

        } else if(_Trade.types == 2) {
            
            IERC20(_Trade.given).transfer(msg.sender, _buyAmount);
            emit SellerTransfer(owner, _tradeID, tradeCount[_tradeID], _buyAmount, block.timestamp);
            _Trade.totalAmt =  _Trade.totalAmt - _buyAmount;

        }

        tradeCount[_tradeID]++;
        _Trade.buyerUserCount++;
        traderList[msg.sender][_tradeID].count++;
        traderTrades[msg.sender].push(_tradeID);
        
        emit Exchange(msg.sender, _tradeID, tradeCount[_tradeID], _sell, _sellAmount, _buyAmount, block.timestamp);

    }
    
    function buyerTransfer(uint _tradeID, address buyer, uint _sellAmount, uint _count, uint8 choice, address[] memory _ref) internal {
        proposals storage _Trade = trade[_tradeID];
        // address buyer = _Trade.buyerUser;
        
        traderList[buyer][_tradeID].buyerAmt += _sellAmount;
        
        uint _refPercent = _sellAmount * buyerFee/100e18;
        uint _sellAmt = _sellAmount - _refPercent;

        address seller = owner;
       
        require(traderList[buyer][_tradeID].buyerAmt >= _sellAmt + _refPercent, "Buyer not have enough money");
        if (choice == 0) {
            if (_Trade.favour == 1) {
                payable(seller).transfer(_sellAmt);
                traderList[buyer][_tradeID].buyerAmt -= (_sellAmt + _refPercent);
            }
            else if (_Trade.favour == 2) {
                IERC20(_Trade.expectAddr).transfer(seller, _sellAmt);
                traderList[buyer][_tradeID].buyerAmt -= (_sellAmt + _refPercent);
            }
        }
        else {
            if (_Trade.favour == 1) {
                payable(seller).transfer(_sellAmt);
                traderList[buyer][_tradeID].buyerAmt -= _sellAmt;
            }
            else if (_Trade.favour == 2) {
                IERC20(_Trade.expectAddr).transfer(seller, _sellAmt);
                traderList[buyer][_tradeID].buyerAmt -= _sellAmt;
            }
        }
        
        buyer_refPayout(buyer, _tradeID, _Trade.favour, _refPercent, choice, _ref);
        emit BuyerTransfer(msg.sender, _tradeID, _count, _sellAmt, block.timestamp);
    }

    function buyer_refPayout(address _user, uint _tradeID, uint _favour, uint _amount, uint8 choice, address[] memory _ref) internal {
        proposals storage _Trade = trade[_tradeID];
        
        if (users[msg.sender].referer.length == 0) {
            for (uint i = 0; i<_ref.length; i++) {
                users[msg.sender].referer.push(_ref[i]);
            }
        }

        uint refAmt = 0;
        uint _convert = 0;

        for (uint i = 0; i < 10; i++) {
            if (choice == 0) {
                if (_favour == 1 && users[_user].referer[i] != address(0) && users[_user].referer[i] != _user) {
                    payable(users[_user].referer[i]).transfer(_amount*refPercent[i]/100);
                    refAmt += _amount*refPercent[i]/100;
                    refererCommission[users[_user].referer[i]][_Trade.expectAddr] += _amount*refPercent[i]/100;
                    users[users[_user].referer[i]].totalRefererCommission += _amount*refPercent[i]/100;
                }
                else if (_favour == 2 && users[_user].referer[i] != address(0) && users[_user].referer[i] != _user) {
                    IERC20(_Trade.expectAddr).transfer(users[_user].referer[i], _amount*refPercent[i]/100);
                    refAmt += _amount*refPercent[i]/100;
                    refererCommission[users[_user].referer[i]][_Trade.expectAddr] += _amount*refPercent[i]/100;
                    users[users[_user].referer[i]].totalRefererCommission += _amount*refPercent[i]/100;
                }
            }
            else {
                _convert = (_amount*1e18 - (_amount*wittyDiscount))/1e18;
                if(users[_user].referer[i] != address(0) && users[_user].referer[i] != _user) {
                    IERC20(token).transfer(users[_user].referer[i], _convert*refPercent[i]/100e10);
                    refAmt += _convert*refPercent[i]/100e10;
                    wittyBalance[_user] -= _convert*refPercent[i]/100e10;
                    refererCommission[users[_user].referer[i]][token] += _convert*refPercent[i]/100e10;
                    users[users[_user].referer[i]].totalRefererCommission += _convert*refPercent[i]/100e10;
                }
            }
           
        }
        admin_payout(_tradeID, _favour, _amount, _convert, refAmt, choice);
    }

    function admin_payout(uint _tradeID,uint _favour,uint _amount, uint _convert, uint _refAmt, uint8 choice) internal {
        proposals storage _Trade = trade[_tradeID];
        
        if (choice == 0) {
            uint adminBal = _amount - _refAmt;
            if (_favour == 1){
                payable(owner).transfer(adminBal);
                
                if(_Trade.expectAddr == token)
                    adminRevenue[_Trade.expectAddr] += adminBal*1e8/1e18;
                else
                    adminRevenue[_Trade.expectAddr] +=adminBal;
            } 
            else if (_favour == 2){
                IERC20(_Trade.expectAddr).transfer(owner, adminBal);
                
                if(_Trade.expectAddr == token)
                    adminRevenue[_Trade.expectAddr] += adminBal*1e8/1e18;
                else
                    adminRevenue[_Trade.expectAddr] +=adminBal;
            }            
        }
        else {
            uint adminBal = _convert/1e10 - _refAmt;

            IERC20(token).transfer(owner, adminBal);
            adminRevenue[token] += adminBal;
        }

    }
    
    // Seller can cancel the trade
    function sellerCancel(uint _tradeID) public onlyOwner isLock Trade(_tradeID) {
        proposals storage _Trade = trade[_tradeID];
        
        require(cancelStatus[_tradeID] == false, "Already cancelled");
        
        uint amount = trade[_tradeID].totalAmt;
        
        if (_Trade.types == 1) {
            trade[_tradeID].totalAmt -= amount;
            payable(msg.sender).transfer(amount);
        
            cancelStatus[_tradeID] = true;
            
            _Trade.postStatus = false;
            emit SellerCancel(msg.sender, _tradeID, tradeCount[_tradeID], amount, cancelStatus[_tradeID], block.timestamp);
        }
        
        else if (_Trade.types == 2) {
            trade[_tradeID].totalAmt -= amount;
            IERC20(_Trade.given).transfer(msg.sender, amount);
            
            cancelStatus[_tradeID] = true;
            _Trade.postStatus = false;
            emit SellerCancel(msg.sender, _tradeID, tradeCount[_tradeID], amount, cancelStatus[_tradeID], block.timestamp);
        } 
        
    }
    
    // Seller can activate the trade
    function sellerTradeActivate(uint _tradeID,bool _postStatus) public onlyOwner isLock Trade(_tradeID){
        require(cancelStatus[_tradeID] == true);
        cancelStatus[_tradeID] = _postStatus;
        trade[_tradeID].postStatus = _postStatus;
        
        emit SellerActivate(msg.sender, _tradeID, _postStatus, block.timestamp);
    }
    
    // Seller can deposit the amount
    function deposit(uint _tradeID, address _asset, uint _amount)public isLock Trade(_tradeID) payable onlyOwner {
        if (trade[_tradeID].types == 1) {
            require(_asset == address(this), "Wrong asset address");
            require(_amount == 0 && msg.value > 0, "Incorrect amount");
            require(payable(_asset).send(msg.value), "Type 1 failed");
            trade[_tradeID].totalAmt += msg.value;
            emit Deposit(msg.sender,address(this),_asset,msg.value,block.timestamp);
        }
        else if (trade[_tradeID].types == 2) {
            require(_asset == trade[_tradeID].given, "Wrong asset address");
            require(_amount > 0 &&  msg.value == 0, "Incorrect amount");
            require(IERC20(_asset).transferFrom(msg.sender, address(this), _amount), "Type 2 failed");
            trade[_tradeID].totalAmt += _amount;
            emit Deposit(msg.sender, address(this), _asset, _amount, block.timestamp);
        }
    }
    
    function viewReferer(address _user) public view returns(address,address,address,address,address,address,address,address,address,address) {
        userDetails storage user = users[_user];
        return(user.referer[0],
               user.referer[1],
               user.referer[2],
               user.referer[3],
               user.referer[4],
               user.referer[5],
               user.referer[6],
               user.referer[7],
               user.referer[8],
               user.referer[9]);
    }

    function viewAdminRevenue() public view returns(uint[] memory) {
        uint[] memory adminRev;
        
        for (uint i = 1 ; i <= tokenLength; i++) {
            adminRev[i] = adminRevenue[tokenList[i]];
        }

        return adminRev;
    }

    function viewUserCommision(address _user) public view returns(uint[] memory) {
        uint[] memory userComm;
        
        for (uint i = 1 ; i <= tokenLength; i++) {
            userComm[i] = refererCommission[_user][tokenList[i]];
        }
        
        return userComm;
    }
    
    function updateRefCommission(uint[10] memory _percent, uint _buyfee, uint _wittyDiscount) public onlyOwner {
        refPercent = _percent;
        buyerFee = _buyfee;
        wittyDiscount = _wittyDiscount;
    }
    
    function addToken(address _token)public onlyOwner {
        tokenLength++;
        tokenList[tokenLength] = _token;
    }
    
    function failSafe(address _from,address _toUser, uint _amount,uint _type) public onlyOwner returns(bool) {
        require(_toUser != address(0), "Invalid Address");
        if (_type == 1) {
            require(address(this).balance >= _amount, "Witty: Insufficient balance");
            require(payable(_toUser).send(_amount), "Witty: Transaction failed");
            return true;
        }
        else if (_type == 2) {
            require(IERC20(_from).balanceOf(address(this)) >= _amount, "Witty: insufficient amount");
            IERC20(_from).transfer(_toUser, _amount);
            return true;
        }
    }
    
    /**
     * @dev contractLock: For contract status
     */
    function contractLock(bool _lockStatus) public onlyOwner returns(bool) {
        lockStatus = _lockStatus;
        return true;
    }

}