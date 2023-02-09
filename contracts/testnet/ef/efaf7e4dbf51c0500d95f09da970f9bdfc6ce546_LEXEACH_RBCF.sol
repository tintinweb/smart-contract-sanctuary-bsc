/**
 *Submitted for verification at BscScan.com on 2023-02-08
*/

/**
 *Submitted for verification at BscScan.com on 2022-12-24
*/

/**
 *Submitted for verification at BscScan.com on 2022-12-22
*/

/**
 *Submitted for verification at BscScan.com on 2022-12-07
*/

// Sources flattened with hardhat v2.12.2 https://hardhat.org

// File contracts/Exam.sol

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.5.0;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract Exam {

    address public owner;
    uint256 public passMarks;

    mapping (uint256 => uint256) qAns;
    uint256 public totalQuestions;
    struct User{
        uint256 obtainMarks;
        uint256 lastAttain;
        uint256 totalMarks;
        string  status;
        uint256 percentage;
    }
    mapping(address => User) user;

    constructor () public{
        owner = msg.sender;
    }
    // OnlyOwner Modifier
    modifier onlyOwner {
        require(msg.sender == owner,"ONLY_OWNER_ALLOWED");
        _;
        
    }
// Set Question and Thier Choice
function setQuestion(uint256[] memory questions, uint256[] memory corr_choices) public onlyOwner{
    require(questions.length == corr_choices.length,"NOT_EQUAL_Q_A");
    for(uint256 i=0;i< questions.length; i++){
      qAns[questions[i]] = corr_choices[i];
    }
    totalQuestions = questions.length;
}
// Submit Answer By USER
function subAnswer(uint256[] memory setQuest , uint256[] memory answer) public {
   require(setQuest.length == answer.length,"NOT_EQUAL_Q_A");
   uint256 obtainMarks;
   for(uint256 i=0;i< setQuest.length; i++){
    if(qAns[setQuest[i]] == answer[i]){
        obtainMarks++;
    }
   }
   uint256 percent = (obtainMarks * 100)/totalQuestions;
   user[msg.sender].totalMarks = totalQuestions;
   user[msg.sender].obtainMarks = obtainMarks;
   user[msg.sender].percentage = percent;
   if(percent>passMarks){
      user[msg.sender].status ="pass";
   }else {
    user[msg.sender].status = "fail";
   }
}
// Set Qualifying Marks by Qualifying Marks
function qualifyingMarks(uint256 _qMarks) public onlyOwner {
    require(_qMarks>0,"Should_be_valid");
     passMarks = _qMarks;
}
function isQualified(address _student) public view returns(bool){
    return user[_student].percentage >= passMarks;   
}

}


// File contracts/utils/IBEP20.sol

// File contracts/IBEP20.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.5.0;
// BEP20 Hardhat token = 0x5FbDB2315678afecb367f032d93F642f64180aa3
interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function freezeToken(address recipient, uint256 amount)
        external
        returns (bool);

    function unfreezeToken(address account) external returns (bool);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Unfreeze(
        address indexed _unfreezer,
        address indexed _to,
        uint256 _amount
    );
}


// File contracts/EXPONA_RBCF.sol

// File contracts/ico.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;


contract LEXEACH_RBCF {
    address public ownerWallet;
    uint public currUserID = 0;
    uint public level_income = 0;
    uint public level_incometoken = 0;
    bool public isRewarding;
    struct UserStruct {
        bool isExist;
        uint id;
        uint referrerID;
        uint coreferrerID;
        uint referredUsers;
        uint coreferredUsers;
        uint income;
        uint batchPaid;
        uint autoPoolPayReceived;
        uint missedPoolPayment;
        address autopoolPayReciever;
        uint levelIncomeReceived;
        uint stageIncomeReceived;
        mapping(uint => uint) levelExpired;
    }
    // MATRIX CONFIG FOR AUTO-POOL FUND
    uint private batchSize;
    uint private height;
    // USERS
    mapping(address => UserStruct) public users;
    mapping(uint => address) public userList;
    mapping(uint => uint) public LEVEL_PRICE;
    mapping(uint => uint) public LEVEL_PRICEtoken;
    mapping(address => uint256) public totalFreeze;
    IBEP20 token;
    IBEP20 stableCoin;
    Exam exam;

    uint256 public tokenReward;
    //   mapping(string => address) token; // Token Address Hold with name
    uint public REGESTRATION_FESS;
    uint public REGESTRATION_FESStoken;

    bool ownerPaid;
    // Events
    event SponsorIncome(
        address indexed _user,
        address indexed _referrer,
        uint _time,
        string tokenType
    );
    event LevelsIncome(
        address indexed _user,
        address indexed _referral,
        uint indexed _level,
        uint _time,
        string tokenType
    );
    event stageIncome(
        address indexed _user,
        address indexed _referral,
        uint indexed _level,
        uint _time,
        string tokenType
    );
    event AutopoolIncome(
        string str1,
        address indexed sender,
        address indexed referrer,
        uint indexed height,
        uint time,
        string tokenType
    );
    UserStruct[] private requests;

    uint public Autopool_Level_Income;
    uint public Autopool_Level_Incometoken;

    // Owner Set Token Acceptance Format
    bool isTokenAcceptance = false;
    string tokenAcceptType = "NATIVE-COIN";

    constructor(address _token, address stableCoin_, address exam_) public {
        ownerWallet = msg.sender;
        
        batchSize = 4;
        height = 5;
        
        UserStruct memory userStruct;
        currUserID++;
        REGESTRATION_FESS = 1000000000000000000;// * nthRootSol(currUserID*1e48 , 24);
        LEVEL_PRICE[1] = REGESTRATION_FESS / 5;
        LEVEL_PRICE[2] = REGESTRATION_FESS / 50;
        level_income = REGESTRATION_FESS / 50;
        Autopool_Level_Income = REGESTRATION_FESS / 10 / height;

        //REGESTRATION_FESStoken = 500000000000000000 * nthRootSol(currUserID*1e48 , 24) / tokenPrice() * 1e18;
        REGESTRATION_FESStoken = (REGESTRATION_FESS * 1e18) / tokenPrice();
        LEVEL_PRICEtoken[1] = REGESTRATION_FESStoken / 5;
        LEVEL_PRICEtoken[2] = REGESTRATION_FESStoken / 50;
        level_incometoken = REGESTRATION_FESStoken / 50;
        Autopool_Level_Incometoken = REGESTRATION_FESStoken / 10 / height;

        isRewarding = true;
        userStruct = UserStruct({
            isExist: true,
            id: currUserID,
            referrerID: 0,
            coreferrerID:0,
            referredUsers: 0,
            coreferredUsers: 0,
            income: 0,
            batchPaid: 0,
            autoPoolPayReceived: 0,
            missedPoolPayment: 0,
            autopoolPayReciever: ownerWallet,
            levelIncomeReceived: 0,
            stageIncomeReceived: 0
        });

        users[ownerWallet] = userStruct;
        userList[currUserID] = ownerWallet;
        token = IBEP20(_token);
        
        stableCoin = IBEP20(stableCoin_);
        exam = Exam(exam_);
    }

    modifier onlyOwner() {
        require(
            msg.sender == ownerWallet,
            "Only Owner can access this function."
        );
        _;
    }

    function setRegistrationFess(uint fess) public onlyOwner {
        REGESTRATION_FESS = fess;
        REGESTRATION_FESS = REGESTRATION_FESS * nthRootSol(currUserID*1e48 , 24);
        LEVEL_PRICE[1] = REGESTRATION_FESS / 5;
        LEVEL_PRICE[2] = REGESTRATION_FESS / 50;
        level_income = REGESTRATION_FESS / 50;
        Autopool_Level_Income = REGESTRATION_FESS / 10 / height;

        REGESTRATION_FESStoken = REGESTRATION_FESS / tokenPrice() * 1e18;
        LEVEL_PRICEtoken[1] = REGESTRATION_FESStoken / 5;
        LEVEL_PRICEtoken[2] = REGESTRATION_FESStoken / 50;
        level_incometoken = REGESTRATION_FESStoken / 50;
        Autopool_Level_Incometoken = REGESTRATION_FESStoken / 10 / height;
    }

    function getRegistrationFess() public view returns (uint) {
        return REGESTRATION_FESS;
    }

    // Change Token for Reward on register and latter owner can use this token
    function changeToken(address _tokenAddress) public onlyOwner {
        require(_tokenAddress != address(0), "Invalid Token Address");
        token = IBEP20(_tokenAddress);
    }
    
    function getNextReward() public view returns (uint) {
        return REGESTRATION_FESS / tokenPrice() * 1e18;
    }
    // Change amount of BEP20 token Reward by owner
    function changeTokenReward(uint256 _amount) external onlyOwner {
        tokenReward = _amount;
    }
    function changeRewardStutus(bool _status) external onlyOwner{
        isRewarding = _status;
    }

    function setTokenAcceptance(bool _status) external onlyOwner {
        isTokenAcceptance = _status;
    }
    // Set Stable Coin Accepting on Registration
    function setRegStableCoin(address _token) public onlyOwner{
      stableCoin = IBEP20(_token);
    }

    function Registration(uint _referrerID, uint _coreferrerID,uint256 _amount) public payable {
        require(!users[msg.sender].isExist, "User Exists");
        require(_referrerID > 0 && _referrerID <= currUserID,"Incorrect referral ID");
        require(_coreferrerID > 0,"Incorrect referral ID");
        require(exam.isQualified(userList[_coreferrerID]),"CO_REFERRER_NOT_QUALIFIED");
        if(_coreferrerID != 1){
        require(users[userList[_coreferrerID]].referredUsers >=2,"Co-Referral-should-be-2");
        }
           if (!isTokenAcceptance) {
            if(msg.value >0){
            require(msg.value == REGESTRATION_FESS, "Incorrect Value");
            }else{
            require(_amount == REGESTRATION_FESS, "Incorrect Value");
            require(stableCoin.allowance(msg.sender, address(this)) >= _amount,"NEED_TO_APPROVE_TOKEN"); 
            stableCoin.transferFrom(msg.sender, address(this), _amount);
            tokenReward =  (_amount * 1e18) / tokenPrice();
            }
        } else {
            
            require(_amount == (REGESTRATION_FESS * 1e18) / tokenPrice(), "Incorrect Value");
            require(token.allowance(msg.sender, address(this)) >= _amount,"NEED_TO_APPROVE_TOKEN");
            token.transferFrom(msg.sender, address(this), _amount);
            tokenReward = _amount ;
        }

        UserStruct memory userStruct;
        currUserID++;
        REGESTRATION_FESS = 1000000000000000000;// * nthRootSol(currUserID*1e48 , 24);
        //REGESTRATION_FESStoken = 500000000000000000 * nthRootSol(currUserID*1e48 , 24) / tokenPrice() * 1e18;
        REGESTRATION_FESStoken = (REGESTRATION_FESS * 1e18) / tokenPrice();
        

        userStruct = UserStruct({
            isExist: true,
            id: currUserID,
            referrerID: _referrerID,
            referredUsers: 0,
            coreferredUsers: 0,
            coreferrerID:_coreferrerID,
            income: 0,
            batchPaid: 0,
            autoPoolPayReceived: 0,
            missedPoolPayment: 0,
            autopoolPayReciever: address(0),
            levelIncomeReceived: 0,
            stageIncomeReceived: 0
        
        });

        users[msg.sender] = userStruct;
        userList[currUserID] = msg.sender;

        users[userList[users[msg.sender].referrerID]].referredUsers =
            users[userList[users[msg.sender].referrerID]].referredUsers +
            1;
        users[userList[users[msg.sender].coreferrerID]].coreferredUsers =
            users[userList[users[msg.sender].coreferrerID]].coreferredUsers +
            1;    
        if(isRewarding){
        token.freezeToken(msg.sender, tokenReward); // Transfer Rewarded Token
        totalFreeze[msg.sender] = totalFreeze[msg.sender] + tokenReward;
            }else{}
        autoPool(msg.sender,msg.value);
        payReferral(1, msg.sender, msg.value);
        paycoReferral(1, msg.sender, msg.value);
        if (isTokenAcceptance) {
            tokenAcceptType = "EXPONA";
        } else {}
        LEVEL_PRICE[1] = REGESTRATION_FESS / 5;
        LEVEL_PRICE[2] = REGESTRATION_FESS / 100;
        LEVEL_PRICE[3] = REGESTRATION_FESS / 50;
        LEVEL_PRICE[4] = REGESTRATION_FESS / 100*3;
        LEVEL_PRICE[5] = REGESTRATION_FESS / 100*4;
        LEVEL_PRICE[6] = REGESTRATION_FESS / 100*5;
        LEVEL_PRICE[7] = REGESTRATION_FESS / 100*6;
        level_income = REGESTRATION_FESS / 100*7;
        Autopool_Level_Income = REGESTRATION_FESS / 10 / height;
        LEVEL_PRICEtoken[1] = REGESTRATION_FESStoken / 5;
        LEVEL_PRICEtoken[2] = REGESTRATION_FESStoken / 50;
        level_incometoken = REGESTRATION_FESStoken / 50;
        Autopool_Level_Incometoken = REGESTRATION_FESStoken / 10 / height;
        emit SponsorIncome(
            msg.sender,
            userList[_referrerID],
            now,
            tokenAcceptType
        );
    }

    function heightPayment(
        address _user,
        uint batch,
        uint id,
        uint h,
        uint256 _value
     ) internal {
        bool sent = false;
        if (
            (users[userList[id]].autopoolPayReciever != address(0)) &&
            (userList[batch] != users[userList[id]].autopoolPayReciever) &&
            (h <= height && h <= 2 && id > 0 && ownerPaid != true)
        ) {
            address nextLevel = userList[id];
            if (!isTokenAcceptance) {
                if(_value > 0){
                sent = address(uint160(nextLevel)).send(Autopool_Level_Income);
                }else{
                   sent = stableCoin.transfer(address(uint160(nextLevel)), Autopool_Level_Income);

                //    sent = stableCoin.transferFrom(msg.sender,address(uint160(nextLevel)), Autopool_Level_Income);
                }
            } else {
                sent = token.transfer(
                    address(uint160(nextLevel)),
                    Autopool_Level_Incometoken
                );
            }
            users[userList[id]].income =
                users[userList[id]].income +
                Autopool_Level_Income;
            users[userList[id]].autoPoolPayReceived =
                users[userList[id]].autoPoolPayReceived +
                1;
            if (id == 1) {
                ownerPaid = true;
            }
            if (sent) {
                if (h == 4) {
                    token.unfreezeToken(nextLevel);
                    if (isTokenAcceptance) {
                        tokenAcceptType = "EXPONA";
                    } else {}
                    emit AutopoolIncome(
                        "Auto-Pool Payment Successful",
                        _user,
                        nextLevel,
                        h,
                        now,
                        tokenAcceptType
                    );
                } else {
                    if (isTokenAcceptance) {
                        tokenAcceptType = "EXPONA";
                    } else {}
                    emit AutopoolIncome(
                        "Auto-Pool Payment Successful",
                        _user,
                        nextLevel,
                        h,
                        now,
                        tokenAcceptType
                    );
                }
            }
            id = users[users[userList[id]].autopoolPayReciever].id;
            heightPayment(_user, batch, id, h + 1,_value);
        } else {
            if (
                (h > 2 && h <= height) &&
                users[userList[id]].referredUsers >= 2 &&
                (id > 0 && ownerPaid != true)
            ) {
                address nextLevel = userList[id];
                if (!isTokenAcceptance) {
                    if(_value>0){
                    sent = address(uint160(nextLevel)).send(
                        Autopool_Level_Income
                    );
                    }else{
                   sent = stableCoin.transfer(address(uint160(nextLevel)), Autopool_Level_Income);

                    }
                } else {
                    sent = token.transfer(
                        // msg.sender,
                        address(uint160(nextLevel)),
                        Autopool_Level_Incometoken
                    );
                }
                users[userList[id]].income =
                    users[userList[id]].income +
                    Autopool_Level_Income;
                users[userList[id]].autoPoolPayReceived =
                    users[userList[id]].autoPoolPayReceived +
                    1;
                if (id == 1) {
                    ownerPaid = true;
                }
                if (sent) {
                    if (h == 4) {
                        token.unfreezeToken(nextLevel);
                        if (isTokenAcceptance) {
                            tokenAcceptType = "EXPONA";
                        } else {}
                        emit AutopoolIncome(
                            "Auto-Pool Payment Successful",
                            _user,
                            nextLevel,
                            h,
                            now,
                            tokenAcceptType
                        );
                    } else {
                        if (isTokenAcceptance) {
                            tokenAcceptType = "EXPONA";
                        } else {}
                        emit AutopoolIncome(
                            "Auto-Pool Payment Successful",
                            _user,
                            nextLevel,
                            h,
                            now,
                            tokenAcceptType
                        );
                    }
                }
                id = users[users[userList[id]].autopoolPayReciever].id;
                heightPayment(_user, batch, id, h + 1,_value);
            } else if (id > 0 && h <= height && ownerPaid != true) {
                if (id == 1) {
                    ownerPaid = true;
                }
                users[userList[id]].missedPoolPayment =
                    users[userList[id]].missedPoolPayment +
                    1;
                id = users[users[userList[id]].autopoolPayReciever].id;
                heightPayment(_user, batch, id, h + 1, _value);
            }
        }
    }

    function autoPool(address _user, uint256 _value) internal {
        bool sent = false;
        ownerPaid = false;
        uint i;
        for (i = 1; i < currUserID; i++) {
            if (users[userList[i]].batchPaid < batchSize) {
                if (!isTokenAcceptance) {
                    if(_value>0){
                    sent = address(uint160(userList[i])).send(
                        Autopool_Level_Income
                    );
                    }else{
                        // Need to Add USDT
                        sent = stableCoin.transfer(address(uint160(userList[i])), Autopool_Level_Income);
                    }
                } else {
                    sent = token.transfer(
                        // msg.sender,
                        address(uint160(userList[i])),
                        Autopool_Level_Incometoken
                    );
                }
                users[userList[i]].batchPaid = users[userList[i]].batchPaid + 1;
                users[_user].autopoolPayReciever = userList[i];
                users[userList[i]].income =
                    users[userList[i]].income +
                    Autopool_Level_Income;
                users[userList[i]].autoPoolPayReceived =
                    users[userList[i]].autoPoolPayReceived +
                    1;

                if (sent) {
                    if (isTokenAcceptance) {
                        tokenAcceptType = "EXPONA";
                    } else {}
                    emit AutopoolIncome(
                        "Auto-Pool Payment Successful",
                        _user,
                        userList[i],
                        1,
                        now,
                        tokenAcceptType
                    );
                }

                uint heightCounter = 2;
                uint temp = users[users[userList[i]].autopoolPayReciever].id;
                heightPayment(_user, i, temp, heightCounter,_value);
                i = currUserID;
            }
        }
    }

    function findReferrerGeneration(address _first_ref, address _current_user)
        internal
        view
        returns (uint)
    {
        uint i;
        address _user;
        uint generation = 1;
        _user = _current_user;
        for (i = 1; i < currUserID; i++) {
            address referrer = userList[users[_user].referrerID];
            if (referrer != _first_ref) {
                _user = referrer;
                generation++;
            } else {
                return generation;
            }
        }
    }

    function payReferral(uint _level, address _user, uint _value) internal {
        address referer;
        referer = userList[users[_user].referrerID];
        bool sent = false;
        uint level_price_local = 0;
        uint level_price_localtoken = 0;
        if (_level > 7) {
            level_price_local = level_income/2;
            level_price_localtoken = level_incometoken/2;
        } else {
            level_price_local = LEVEL_PRICE[_level];
            level_price_localtoken = LEVEL_PRICEtoken[_level];
        }
        if (!isTokenAcceptance) {
            if(_value>0){
            sent = address(uint160(referer)).send(level_price_local);
            }else {
            sent = stableCoin.transfer(address(uint160(referer)),level_price_local);//.send(level_price_local);
            }
        } else {
            sent = token.transfer(
                // msg.sender,
                address(uint160(referer)),
                level_price_localtoken
            );
        }
        users[referer].levelIncomeReceived =
            users[referer].levelIncomeReceived +
            1;
        users[userList[users[_user].referrerID]].income =
            users[userList[users[_user].referrerID]].income +
            level_price_local;
        if (sent) {
            if (isTokenAcceptance) {
                tokenAcceptType = "EXPONA";
            } else {}
            emit LevelsIncome(
                referer,
                msg.sender,
                _level,
                now,
                tokenAcceptType
            );
            if (_level < 10 && users[referer].referrerID >= 1) {
                payReferral(_level + 1, referer, _value);
               
            } else {
                // sendBalance(_value);
            }
        }
        if (!sent) {
            //  emit lostMoneyForLevelEvent(referer, msg.sender, _level, now);
            payReferral(_level, referer,_value);
        }
    }

      function paycoReferral(uint _level, address _user, uint _value) internal {
        address referer;
        referer = userList[users[_user].coreferrerID];
        bool sent = false;
        uint level_price_local = 0;
        uint level_price_localtoken = 0;
        if (_level > 2) {
            level_price_local = level_income;
            level_price_localtoken = level_incometoken;
        } else {
            level_price_local = LEVEL_PRICE[_level];
            level_price_localtoken = LEVEL_PRICEtoken[_level];
        }
        if (!isTokenAcceptance) {
            if(_value>0){
            sent = address(uint160(referer)).send(level_price_local);
            }else{
              sent = stableCoin.transfer( address(uint160(referer)),level_price_local);// .send(level_price_local);

            }
        } else {
            sent = token.transfer(
                // msg.sender,
                address(uint160(referer)),
                level_price_localtoken
            );
        }
        users[referer].stageIncomeReceived =
            users[referer].stageIncomeReceived +
            1;
        users[userList[users[_user].coreferrerID]].income =
            users[userList[users[_user].coreferrerID]].income +
            level_price_local;
        if (sent) {
            if (isTokenAcceptance) {
                tokenAcceptType = "EXPONA";
            } else {}
            emit stageIncome(
                referer,
                msg.sender,
                _level,
                now,
                tokenAcceptType
            );
            if (_level < 10 && users[referer].coreferrerID >= 1) {
                paycoReferral(_level + 1, referer,_value);
            } else {
                sendBalance(_value);
            }
        }
        if (!sent) {
            //  emit lostMoneyForLevelEvent(referer, msg.sender, _level, now);
            paycoReferral(_level, referer, _value);
        }
    }

    function gettrxBalance(uint256 _value) public view returns (uint) {
        if (!isTokenAcceptance) {
            if(_value>0){
            return address(this).balance;
            }else{
            return  stableCoin.balanceOf(address(this)); //stableCoin.allowance(msg.sender, address(this));
            }
        } else {
            // return token.allowance(msg.sender, address(this));
            return token.balanceOf(address(this));

        }
    }

    function sendBalance(uint _value) private {
        users[ownerWallet].income = users[ownerWallet].income + gettrxBalance(_value);
        if (!isTokenAcceptance) {
            if(_value>0){
            if (!address(uint160(ownerWallet)).send(gettrxBalance(_value))) {}
            }else{
                // if(!stableCoin.transferFrom(msg.sender,address(uint160(ownerWallet)),gettrxBalance(_value))){}
                if(!stableCoin.transfer(address(uint160(ownerWallet)),gettrxBalance(_value))){}

            }
        } else {
            if (
                !token.transfer(
                    // msg.sender,
                    address(uint160(ownerWallet)),
                    gettrxBalance(_value)
                )
            ) {}
        }
    }

    function currentTokenAccepting() public view returns (string memory) {
        if (isTokenAcceptance) {
            return "EXPONA-Accepting";
        } else {
            return "Native-Coin-Accepting";
        }
    }

    // Get Token Price 
    function tokenPrice()public view returns(uint256){
         return sqrt(currUserID * 1e34);
    }


    function sqrt(uint x) internal pure returns (uint y) {
        uint z = (x + 1) / 2;
        y = x;
        while (z < y) {
        y = z;
        z = (x / z + z) / 2;
         }
    }
    // Find Nth Root Of Any Number
    function nthRootSol(uint256 number,uint256 nth)internal pure returns(uint256){
      uint256 k=1;
      uint256  greaterthan;
      uint256 nthIs;
      uint256 lessthan;

    for(uint256 i=1; i<= number; i++){
        for(uint256 j=1; j<=nth; j++){
         k *=i;
        }
        if(k==number){
            nthIs =i;
            break;
        }
        if(k>number){
            greaterthan = k;
            nthIs = i;
            break;
        }
        if(k< number){
            lessthan = k;
             k=1;
        }
    }
    return nthIs;

}

function exp( int256 a,int256  b) public returns(int256){
    int256 t =1;
    for(int256 i = 0;i<b;++i)
        t *= a;
    return t;
}

}