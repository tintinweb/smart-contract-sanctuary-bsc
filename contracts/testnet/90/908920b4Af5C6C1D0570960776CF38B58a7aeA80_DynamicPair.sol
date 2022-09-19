/**
 *Submitted for verification at BscScan.com on 2022-09-19
*/

// File: DynamicSwap-v2-core/contracts/interfaces/IDynamicCallee.sol



pragma solidity >=0.6.0;



interface IDynamicCallee {

    function DynamicCall(address sender, uint amount0, uint amount1, bytes calldata data) external;

}


// File: DynamicSwap-v2-core/contracts/interfaces/IERC20.sol



pragma solidity >=0.6.0;



interface IERC20 {

    event Approval(address indexed owner, address indexed spender, uint value);

    event Transfer(address indexed from, address indexed to, uint value);



    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);



    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);



    function mint(address to, uint256 amount) external returns (bool);

}


// File: DynamicSwap-v2-core/contracts/libraries/UQ112x112.sol



pragma solidity =0.6.12;



// a library for handling binary fixed point numbers (https://en.wikipedia.org/wiki/Q_(number_format))



// range: [0, 2**112 - 1]

// resolution: 1 / 2**112



library UQ112x112 {

    uint224 constant Q112 = 2**112;



    // encode a uint112 as a UQ112x112

    function encode(uint112 y) internal pure returns (uint224 z) {

        z = uint224(y) * Q112; // never overflows

    }



    // divide a UQ112x112 by a uint112, returning a UQ112x112

    function uqdiv(uint224 x, uint112 y) internal pure returns (uint224 z) {

        z = x / uint224(y);

    }

}


// File: DynamicSwap-v2-core/contracts/libraries/Math.sol



pragma solidity =0.6.12;



// a library for performing various math operations



library Math {

    function min(uint x, uint y) internal pure returns (uint z) {

        z = x < y ? x : y;

    }



    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)

    function sqrt(uint y) internal pure returns (uint z) {

        if (y > 3) {

            z = y;

            uint x = y / 2 + 1;

            while (x < z) {

                z = x;

                x = (y / x + x) / 2;

            }

        } else if (y != 0) {

            z = 1;

        }

    }

}


// File: DynamicSwap-v2-core/contracts/interfaces/IDynamicFactory.sol



pragma solidity >=0.6.0;



interface IDynamicFactory {

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);



    function dynamic() external view returns (address);

    function WETH() external view returns (address);

    function uniV2Router() external view returns (address);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);



    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);



    function createPair(address tokenA, address tokenB) external returns (address pair);

    function createPair(

        address tokenA, 

        address tokenB, 

        uint32[8] calldata _vars, 

        bool isPrivate, // is private pool

        address protectedToken, // which token should be protected by secure floor, if address(0) then without secure floor

        uint32[2] memory voteVars // [0] - voting delay, [1] - minimal level for proposal in percentage with 2 decimals i.e. 100 = 1%

    ) external returns (address pair);

    

    //function setFeeTo(address) external;

    function setFeeToSetter(address) external;



    function mintReward(address to, uint amount) external;

    function swapFee(address token0, address token1, uint fee0, uint fee1) external returns(bool);

    function setVars(uint varId, uint32 value) external;

    function setRouter(address _router) external;

    function setReimbursementContractAndVault(address _reimbursement, address _vault) external;

    function claimFee() external returns (uint256);

    function getColletedFees() external view returns (uint256 feeAmount);

    function pairImplementation() external view returns (address);

}


// File: DynamicSwap-v2-core/contracts/libraries/SafeMath.sol



pragma solidity =0.6.12;



// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)



library SafeMath {

    function add(uint x, uint y) internal pure returns (uint z) {

        require((z = x + y) >= x, 'ds-math-add-overflow');

    }



    function sub(uint x, uint y) internal pure returns (uint z) {

        require((z = x - y) <= x, 'ds-math-sub-underflow');

    }



    function mul(uint x, uint y) internal pure returns (uint z) {

        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');

    }



    function div(uint x, uint y) internal pure returns (uint z) {

        z = x/y;

    }

}


// File: DynamicSwap-v2-core/contracts/DynamicERC20.sol



pragma solidity =0.6.12;



//import './interfaces/IDynamicERC20.sol';





contract DynamicERC20 {

    using SafeMath for uint;



    address public factory;

    uint public accumulatedRewardPerShare;

    mapping(address => uint) public userRewardPerSharePaid;

    mapping(address => uint) public userEarnedRewards;



    string public name;

    string public symbol;

    uint8 public constant decimals = 18;

    uint  public totalSupply;

    mapping(address => uint) public balanceOf;

    mapping(address => mapping(address => uint)) public allowance;



    bytes32 public DOMAIN_SEPARATOR;

    // keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;

    mapping(address => uint) public nonces;

    mapping(address => uint) public locked;   // lock token until end of voting (timestamp)



    event Approval(address indexed owner, address indexed spender, uint value);

    event Transfer(address indexed from, address indexed to, uint value);

    event AddReward(uint reward);



    function initialize() internal virtual {

        uint256 chainId;

        assembly {

            chainId := chainid()

        }



        DOMAIN_SEPARATOR = keccak256(

            abi.encode(

                keccak256('EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)'),

                keccak256(bytes(name)),

                keccak256(bytes('1')),

                chainId,

                address(this)

            )

        );

        //super.initialize();

    }



    // add reward tokens into the reward pool (only by factory)

    function addReward(uint amount) external {

        require(msg.sender == factory, "Only factory");

        accumulatedRewardPerShare = accumulatedRewardPerShare.add(amount.mul(1e18).div(totalSupply));

        emit AddReward(amount);

    }



    // View function to see pending Reward on frontend.

    function pendingReward(address user) public view returns (uint) {

        return (balanceOf[user].mul(accumulatedRewardPerShare.sub(userRewardPerSharePaid[user])).div(1e18)).add(userEarnedRewards[user]);

    }



    function _updateReward(address user, bool shouldPay) internal {

            uint pendingAmount = pendingReward(user);

            if (shouldPay && pendingAmount != 0) {

                userEarnedRewards[user] = 0;

                IDynamicFactory(factory).mintReward(user, pendingAmount);

            } else {

                userEarnedRewards[user] = pendingAmount;

            }

            userRewardPerSharePaid[user] = accumulatedRewardPerShare;

    }



    function _mint(address to, uint value) internal {

        if (to != address(0)) _updateReward(to, false);

        totalSupply = totalSupply.add(value);

        balanceOf[to] = balanceOf[to].add(value);

        emit Transfer(address(0), to, value);

    }



    function _burn(address from, uint value) internal {

        if (from != address(this)) _updateReward(from, false); 

        balanceOf[from] = balanceOf[from].sub(value);

        totalSupply = totalSupply.sub(value);

        emit Transfer(from, address(0), value);

    }



    function _approve(address owner, address spender, uint value) private {

        allowance[owner][spender] = value;

        emit Approval(owner, spender, value);

    }



    function _transfer(address from, address to, uint value) internal {

        require(locked[from] < block.timestamp, "LP locked until end of voting");

        _updateReward(from, true);  // transfer rewards when transfer LP tokens

        _updateReward(to, false);

        balanceOf[from] = balanceOf[from].sub(value);

        balanceOf[to] = balanceOf[to].add(value);

        emit Transfer(from, to, value);

    }



    function approve(address spender, uint value) external returns (bool) {

        _approve(msg.sender, spender, value);

        return true;

    }



    function transfer(address to, uint value) external returns (bool) {

        _transfer(msg.sender, to, value);

        return true;

    }



    function transferFrom(address from, address to, uint value) external returns (bool) {

        if (value == 0) return true;

        if (allowance[from][msg.sender] != uint(-1)) {

            allowance[from][msg.sender] = allowance[from][msg.sender].sub(value);

        }

        _transfer(from, to, value);

        return true;

    }



    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external {

        require(deadline >= block.timestamp, 'Dynamic: EXPIRED');

        bytes32 digest = keccak256(

            abi.encodePacked(

                '\x19\x01',

                DOMAIN_SEPARATOR,

                keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner]++, deadline))

            )

        );

        address recoveredAddress = ecrecover(digest, v, r, s);

        require(recoveredAddress != address(0) && recoveredAddress == owner, 'Dynamic: INVALID_SIGNATURE');

        _approve(owner, spender, value);

    }

}


// File: DynamicSwap-v2-core/contracts/DynamicVoting.sol



pragma solidity =0.6.12;






contract DynamicVoting is DynamicERC20 {

    uint256 public votingTime;   // duration of voting

    uint256 public minimalLevel; // user who has this percentage of token can suggest change (with 2 decimals: 100 = 1%)

    

    uint256 public ballotIds;

    uint256 public rulesIds;

    

    enum Status {New , Executed}



    struct Rule {

        //address contr;      // contract address which have to be triggered

        uint32 majority;  // require more than this percentage of participants voting power (in according tokens).

        string funcAbi;     // function ABI (ex. "transfer(address,uint256)")

    }



    struct Ballot {

        uint256 closeVote; // timestamp when vote will close

        uint256 ruleId; // rule which edit

        bytes args; // ABI encoded arguments for proposal which is required to call appropriate function

        Status status;

        address creator;    // wallet address of ballot creator.

        uint256 yea;  // YEA votes according communities (tokens)

        uint256 totalVotes;  // The total voting power od all participant according communities (tokens)

    }

    

    mapping(address => mapping(uint256 => uint256)) public voted;

    mapping(uint256 => Ballot) public ballots;

    mapping(uint256 => Rule) public rules;

    //event AddRule(address indexed contractAddress, string funcAbi, uint32 majorMain);

    event ApplyBallot(uint256 indexed ruleId, uint256 indexed ballotId, bytes args);

    event BallotCreated(uint256 indexed ruleId, uint256 indexed ballotId, bytes args, address creator, uint256 closeVote);

    event Vote(uint256 ballotId, address voter, bool yea, uint256 voteLP);

    

    modifier onlyVoting() {

        require(address(this) == msg.sender, "Only voting");

        _;        

    }



    function initialize() internal virtual override {

        rules[0] = Rule(50,"setVotingDuration(uint256)");

        rules[1] = Rule(50,"setMinimalLevel(uint256)");

        rules[2] = Rule(50,"setVars(uint256,uint32)");

        rules[3] = Rule(50,"switchToPublic()");      // switch pool from private to public

        rulesIds = 3;

        //votingTime = 1 days;

        //minimalLevel = 100; // 1%

        super.initialize();

    }

    

    /**

     * @dev Add new rule - function that call target contract to change setting.

        * @param contr The contract address which have to be triggered

        * @param majority The majority level (%) for the tokens 

        * @param funcAbi The function ABI (ex. "transfer(address,uint256)")

     */

     /*

    function addRule(

        address contr,

        uint32  majority,

        string memory funcAbi

    ) external onlyOwner {

        require(contr != address(0), "Zero address");

        rulesIds +=1;

        rules[rulesIds] = Rule(contr, majority, funcAbi);

        emit AddRule(contr, funcAbi, majority);

    }

    */



    /**

     * @dev Set voting duration

     * @param time duration in seconds

    */

    function setVotingDuration(uint256 time) external onlyVoting {

        require(time >= 1 days);

        votingTime = time;

    }

    

    /**

     * @dev Set minimal level to create proposal

     * @param level in percentage with 2 decimals. I.e. 1000 = 10%

    */

    function setMinimalLevel(uint256 level) external onlyVoting {

        require(level > 0 && level <= 5100);    // less than 51% and more than 0

        minimalLevel = level;

    }

    

    /**

     * @dev Get rules details.

     * @param ruleId The rules index

     * @return majority The level of majority in according tokens

     * @return funcAbi The function Abi (ex. "transfer(address,uint256)")

    */

    function getRule(uint256 ruleId) external view returns(uint32 majority, string memory funcAbi) {

        Rule storage r = rules[ruleId];

        return (r.majority, r.funcAbi);

    }

    

    function _checkMajority(uint32 majority, uint256 _ballotId) internal view returns(bool){

        Ballot storage b = ballots[_ballotId];

        if (b.yea * 2 > totalSupply) {

            return true;

        }

        if((b.totalVotes - b.yea) * 2 > totalSupply){

            return false;

        }

        if (block.timestamp >= b.closeVote && b.yea > b.totalVotes * majority / 100) {

            return true;

        }

        return false;

    }



    function vote(uint256 _ballotId, bool yea) external returns (bool){

        vote(_ballotId, yea, uint256(2**127));

    }

    

    function vote(uint256 _ballotId, bool yea, uint256 voteLP) public returns (bool){

        require(_ballotId <= ballotIds, "ballot ID");

        uint256 power = balanceOf[msg.sender];

        uint256 votedPower = voted[msg.sender][_ballotId];

        require(votedPower < power, "already voted");

        if (power < voteLP + votedPower) voteLP = power - votedPower;   //if voteLP too big, vote with all available LP



        Ballot storage b = ballots[_ballotId];

        uint256 closeVote = b.closeVote;

        require(closeVote > block.timestamp, "voting closed");

        

        if(yea){

            b.yea += voteLP;    

        }

        b.totalVotes += voteLP;

        voted[msg.sender][_ballotId] += voteLP;

        emit Vote(_ballotId, msg.sender, yea, voteLP);



        if(_checkMajority(rules[b.ruleId].majority, _ballotId)) {

            _executeBallot(_ballotId);

        } else if (locked[msg.sender] < closeVote) {

            locked[msg.sender] = closeVote;

        }

        return true;

    }



    function createBallot(uint256 ruleId, bytes calldata args, uint256 voteLP) external {

        require(ruleId <= rulesIds, "rule ID");

        Rule storage r = rules[ruleId];

        uint256 power = balanceOf[msg.sender];

        if (power < voteLP) voteLP = power;   //if voteLP too big, vote with all available LP



        require(voteLP >= totalSupply * minimalLevel / 10000, "minimal Level");

        uint256 closeVote = block.timestamp + votingTime;

        ballotIds += 1;

        Ballot storage b = ballots[ballotIds];

        b.ruleId = ruleId;

        b.args = args;

        b.creator = msg.sender;

        b.yea = voteLP;

        b.totalVotes = voteLP;

        b.closeVote = closeVote;

        b.status = Status.New;

        voted[msg.sender][ballotIds] = voteLP;

        emit BallotCreated(ruleId, ballotIds, args, msg.sender, closeVote);

        emit Vote(ballotIds, msg.sender, true, voteLP);

        

        if (_checkMajority(r.majority, ballotIds)) {

            _executeBallot(ballotIds);

        } else if (locked[msg.sender] < closeVote) {

            locked[msg.sender] = closeVote;

        }

    }

    

    function executeBallot(uint256 _ballotId) external {

        Ballot storage b = ballots[_ballotId];

        if(_checkMajority(rules[b.ruleId].majority, _ballotId)){

            _executeBallot(_ballotId);

        }

    }

    

    

    /**

     * @dev Apply changes from ballot.

     * @param ballotId The ballot index

     */

    function _executeBallot(uint256 ballotId) internal {

        Ballot storage b = ballots[ballotId];

        require(b.status != Status.Executed,"Ballot is Executed");

        Rule storage r = rules[b.ruleId];

        bytes memory command = abi.encodePacked(bytes4(keccak256(bytes(r.funcAbi))), b.args);

        trigger(address(this), command);

        b.closeVote = block.timestamp;

        b.status = Status.Executed;

        emit ApplyBallot(b.ruleId, ballotId, b.args);

    }



    

    /**

     * @dev Apply changes from Governance System. Call destination contract.

     * @param contr The contract address to call

     * @param params encoded params

     */

    function trigger(address contr, bytes memory params) internal  {

        (bool success,) = contr.call(params);

        require(success, "Trigger error");

    }

}
// File: DynamicSwap-v2-core/contracts/DynamicPair.sol



pragma solidity =0.6.12;



//import './interfaces/IDynamicPair.sol';





//import './interfaces/IDynamicFactory.sol';




interface Ownable {

    function owner() external view returns(address);

} 



// This contract is implementation of code for pair.

contract DynamicPair is DynamicVoting {

    using SafeMath for uint256;

    using UQ112x112 for uint224;



    enum Vars {

        timeFrame,

        maxDump0,

        maxDump1,

        maxTxDump0,

        maxTxDump1,

        coefficient,

        minimalFee,

        periodMA

    }

    uint32[8] public vars; // timeFrame, maxDump0, maxDump1, maxTxDump0, maxTxDump1, coefficient, minimalFee, periodM

    //timeFrame = 1 days;  // during this time frame rate of reserve1/reserve0 should be in range [baseLinePrice0*(1-maxDump0), baseLinePrice0*(1+maxDump1)]

    //maxDump0 = 10000;   // maximum allowed dump (in percentage with 2 decimals) of reserve1/reserve0 rate during time frame relatively the baseline

    //maxDump1 = 10000;   // maximum allowed dump (in percentage with 2 decimals) of reserve0/reserve1 rate during time frame relatively the baseline

    //maxTxDump0 = 10000; // maximum allowed dump (in percentage with 2 decimals) of token0 price per transaction

    //maxTxDump1 = 10000; // maximum allowed dump (in percentage with 2 decimals) of token1 price per transaction

    //coefficient = 10000; // coefficient (in percentage with 2 decimals) to transform price growing into fee. ie

    //minimalFee = 5;   // Minimal fee percentage (with 2 decimals) applied to transaction. I.e. 5 = 0.05%

    //periodMA = 45*60;  // MA period in seconds



    uint256 public baseLinePrice0; // base line of reserve1/reserve0 rate saved on beginning of each time frame.

    uint256 public baseLineLP; // base line of total LP saved on beginning of each time frame.

    uint256 public lastPeriodCounter; // base line saved at this period number (block.timestamp / timeFrame)

    uint256 public lastMA; // last MA value



    uint256 public constant MINIMUM_LIQUIDITY = 10**3;



    //address public factory;

    address public token0;

    address public token1;

    bool public isPrivate; // in private pool only LP holder (creator) can add more liquidity



    uint112 private reserve0; // uses single storage slot, accessible via getReserves

    uint112 private reserve1; // uses single storage slot, accessible via getReserves

    uint32 private blockTimestampLast; // uses single storage slot, accessible via getReserves



    uint256 public price0CumulativeLast;

    uint256 public price1CumulativeLast;

    uint256 public kLast; // reserve0 * reserve1, as of immediately after the most recent liquidity event



    uint256 private unlocked;

    uint256 creationBlock; // protection from fork using flash loan

    struct FloorPrice {

        uint224 floorPrice0; // floor price on pair creation (reserve1/reserve0)

        uint32 baseToken; // number of base token (0, 1) to check floor pice. If disabled = 2

    }

    FloorPrice public floorPrice0;



    struct TaxToken {

        address token; // token that has tax (address(0) if no tax)

        address buyTaxReceiver; // address that receive buy tax

        uint256 buyTax; // tax when buy "token" (in percentage with 2 decimals)

        address sellTaxReceiver; // address that receive sell tax

        uint256 sellTax; // tax when sell "token" (in percentage with 2 decimals)

    }

    TaxToken public taxToken;



    modifier lock() {

        require(unlocked == 1, "Dynamic: LOCKED");

        unlocked = 2;

        _;

        unlocked = 1;

    }



    // returns floor price of baseToken (in another token) with 18 decimals and current base token address.

    // returns 0 when baseToken does not match with tokens in pair.

    function getFloorPrice(address baseToken)

        external

        view

        returns (uint256 floorPrice, address currentBaseToken)

    {

        floorPrice = (((floorPrice0.floorPrice0 * 1e9) / 2**56) * 1e9) / 2**56; // floor price of token0 with 18 decimals

        if (floorPrice0.baseToken == 0) currentBaseToken = token0;

        else if (floorPrice0.baseToken == 1) currentBaseToken = token1;

        if (baseToken == token1) {

            floorPrice = 1e36 / floorPrice;

        } else if (baseToken != token0) {

            floorPrice = 0;

        }

    }



    function getReserves()

        public

        view

        returns (

            uint112 _reserve0,

            uint112 _reserve1,

            uint32 _blockTimestampLast

        )

    {

        _reserve0 = reserve0;

        _reserve1 = reserve1;

        _blockTimestampLast = blockTimestampLast;

    }



    function _safeTransfer(

        address token,

        address to,

        uint256 value

    ) private {

        (bool success, bytes memory data) = token.call(

            abi.encodeWithSelector(0xa9059cbb, to, value) // bytes4(keccak256(bytes('transfer(address,uint256)')));

        );

        require(

            success && (data.length == 0 || abi.decode(data, (bool))),

            "Dynamic: TRANSFER_FAILED"

        );

    }



    event Mint(address indexed sender, uint256 amount0, uint256 amount1);

    event Burn(

        address indexed sender,

        uint256 amount0,

        uint256 amount1,

        address indexed to

    );

    event Swap(

        address indexed sender,

        uint256 amount0In,

        uint256 amount1In,

        uint256 amount0Out,

        uint256 amount1Out,

        address indexed to

    );

    event Sync(uint112 reserve0, uint112 reserve1);



    // called once by the factory at time of deployment

    function initialize(

        address _token0,

        address _token1,

        uint32[8] calldata _vars,

        bool _isPrivate,

        uint256 baseProtectedToken,

        uint32[2] memory voteVars

    ) external {

        require(address(0) == factory, "Dynamic: FORBIDDEN"); // sufficient check

        unlocked = 1;

        factory = msg.sender;

        token0 = _token0;

        token1 = _token1;

        vars = _vars;

        isPrivate = _isPrivate;

        name = string(

            abi.encodePacked(

                IERC20(_token0).symbol(),

                "-",

                IERC20(_token1).symbol(),

                " LP"

            )

        );

        symbol = name;

        floorPrice0.baseToken = uint32(baseProtectedToken);

        votingTime = voteVars[0];

        minimalLevel = voteVars[1];



        super.initialize();

    }



    function getAmountOut(

        uint256 amountIn,

        address tokenIn,

        address tokenOut

    ) external view returns (uint256 amountOut) {

        (amountOut, ) = getAmountOutAndFee(amountIn, tokenIn, tokenOut);

    }



    function getAmountOutAndFee(

        uint256 amountIn,

        address tokenIn,

        address tokenOut

    ) public view returns (uint256 amountOut, uint256 fee) {

        uint32[8] memory _vars = vars;

        uint256 balanceIn;

        uint112 reserveOut = reserve1;

        uint112 reserveIn = reserve0;

        uint256 ma;

        {

            if(taxToken.token == tokenOut) {

                // buy token

                amountIn = amountIn * (10000 - taxToken.buyTax) / 10000;

            }

        }

        {

            uint32 blockTimestamp = uint32(block.timestamp % 2**32);

            uint32 timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired

            uint256 priceBefore0 = uint256(

                UQ112x112.encode(reserveOut).uqdiv(reserveIn)

            );

            if (timeElapsed >= _vars[uint256(Vars.periodMA)]) ma = priceBefore0;

            else

                ma =

                    ((_vars[uint256(Vars.periodMA)] - timeElapsed) *

                        lastMA +

                        priceBefore0 *

                        timeElapsed) /

                    _vars[uint256(Vars.periodMA)];

        }

        {

            amountOut = amountIn.mul(_vars[uint256(Vars.coefficient)]) / 10000; // reuse amountOut

            uint256 b;

            uint256 c;

            ma = ma / 2**56;

            {

                uint256 k = uint256(reserveIn).mul(reserveOut); // / denominator;

                uint256 denominator = _getDenominator(k);

                k = k / denominator;

                if (tokenIn < tokenOut) {

                    balanceIn = amountIn.add(reserveIn);

                    b = balanceIn.mul(ma) / 2**56;

                    b = b.mul(balanceIn.sub(amountOut));

                    b = b / denominator;

                    //b = (uint(reserveIn).mul(ma) / 2**56).mul(balanceIn) / denominator;

                    c = (k.mul(ma) / 2**56).mul(balanceIn);

                } else {

                    (reserveIn, reserveOut) = (reserveOut, reserveIn);

                    balanceIn = amountIn.add(reserveIn);

                    b = balanceIn.mul(2**56) / ma;

                    b = b.mul(balanceIn.sub(amountOut));

                    b = b / denominator;

                    //b = (uint(reserveIn).mul(2**56) / ma).mul(balanceIn) / denominator;

                    c = (k.mul(2**56) / ma).mul(balanceIn);

                }



                if (amountOut != 0) {

                    c = c / denominator;

                    fee = sqrt(b.mul(b).add(c.mul(amountOut * 4)));

                    amountOut = (fee.sub(b).mul(denominator)) / (amountOut * 2);

                } else {

                    amountOut = c / b;

                }

            }

        }



        // amountOut = balanceOut

        if (tokenIn < tokenOut) {

            fee = amountOut.mul(10000).mul(2**56) / (balanceIn.mul(ma));

        } else {

            fee = amountOut.mul(10000).mul(ma) / (balanceIn.mul(2**56));

        }

        fee = fee < 10000 ? 10000 - fee : 0;

        amountOut = uint256(reserveOut).sub(amountOut);



        if (fee < _vars[uint256(Vars.minimalFee)]) {

            fee = _vars[uint256(Vars.minimalFee)];

        }

        if (fee == _vars[uint256(Vars.minimalFee)] || amountIn < 1e14) {

            uint256 amountInWithFee = amountIn.mul(10000 - fee);

            uint256 numerator = amountInWithFee.mul(reserveOut);

            uint256 denominator = uint256(reserveIn).mul(10000).add(

                amountInWithFee

            );

            amountOut = numerator / denominator;

        }

        {

            if(taxToken.token == tokenIn) {

                // sell token

                amountOut = amountOut * (10000 - taxToken.sellTax) / 10000;

            }

        }

    }



    function getAmountIn(

        uint256 amountOut,

        address tokenIn,

        address tokenOut

    ) external view returns (uint256 amountIn) {

        (amountIn, ) = getAmountInAndFee(amountOut, tokenIn, tokenOut);

    }



    function getAmountInAndFee(

        uint256 amountOut,

        address tokenIn,

        address tokenOut

    ) public view returns (uint256 amountIn, uint256 fee) {

        uint32[8] memory _vars = vars;

        uint256 ma;

        uint112 reserveIn = reserve0;

        uint112 reserveOut = reserve1;

        uint256 balanceOut;

        {

            if(taxToken.token == tokenIn) {

                // sell token

                amountOut = amountOut * 10000 / (10000 - taxToken.sellTax) + 1;

            }

        }

        {

            {

                uint32 blockTimestamp = uint32(block.timestamp % 2**32);

                uint32 timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired

                uint256 priceBefore0 = uint256(

                    UQ112x112.encode(reserveOut).uqdiv(reserveIn)

                );

                if (timeElapsed >= _vars[uint256(Vars.periodMA)])

                    ma = priceBefore0;

                else

                    ma =

                        ((_vars[uint256(Vars.periodMA)] - timeElapsed) *

                            lastMA +

                            priceBefore0 *

                            timeElapsed) /

                        _vars[uint256(Vars.periodMA)];

            }

            uint256 b;

            uint256 c;

            uint256 denominator;

            ma = ma / 2**56;

            {

                if (tokenIn < tokenOut) {

                    balanceOut = uint256(reserveOut).sub(amountOut);

                    fee = uint256(reserveIn).mul(ma) / 2**56;

                    amountIn =

                        balanceOut.mul(

                            10000 - _vars[uint256(Vars.coefficient)]

                        ) /

                        10000;

                    amountIn = amountIn.mul(ma) / 2**56; // reuse amountIn

                } else {

                    (reserveIn, reserveOut) = (reserveOut, reserveIn);

                    balanceOut = uint256(reserveOut).sub(amountOut);

                    fee = uint256(reserveIn).mul(2**56) / ma; // reuse fee

                    amountIn =

                        balanceOut.mul(

                            10000 - _vars[uint256(Vars.coefficient)]

                        ) /

                        10000;

                    amountIn = amountIn.mul(2**56) / ma; // reuse amountIn

                }

                b =

                    fee.mul(balanceOut).mul(

                        20000 - _vars[uint256(Vars.coefficient)]

                    ) /

                    10000;

                denominator = _getDenominator(b);

                b = b.add(

                    (balanceOut.mul(_vars[uint256(Vars.coefficient)]) / 10000)

                        .mul(balanceOut)

                );

                b = b.sub(fee.mul(reserveOut));

                b = b / denominator;



                c = fee.mul(reserveIn) / denominator;

                c = c.mul(amountOut);

            }

            if (amountIn != 0) {

                c = c / denominator;

                fee = sqrt(b.mul(b).add(c.mul(amountIn * 4)));

                amountIn = (fee.sub(b).mul(denominator)) / (amountIn * 2);

            } else {

                amountIn = c / b;

            }

        }



        {

            uint256 balanceIn = amountIn.add(reserveIn);

            if (tokenIn < tokenOut) {

                fee = balanceOut.mul(10000 * 2**56) / (balanceIn.mul(ma));

            } else {

                fee = balanceOut.mul(10000 * ma) / (balanceIn.mul(2**56));

            }

            fee = fee < 10000 ? 10000 - fee : 0;



            if (fee < _vars[uint256(Vars.minimalFee)]) {

                fee = _vars[uint256(Vars.minimalFee)];

                uint256 numerator = uint256(reserveIn).mul(amountOut).mul(

                    10000

                );

                uint256 denominator = uint256(reserveOut).sub(amountOut).mul(

                    10000 - fee

                );

                amountIn = (numerator / denominator).add(1);

            }

        }

        {

            if(taxToken.token == tokenOut) {

                // buy token

                amountIn = amountIn * 10000 / (10000 - taxToken.sellTax) + 1;

            }

        }

    }



    function _getFeeAndDumpProtection(

        uint256 balance0,

        uint256 balance1,

        uint112 _reserve0,

        uint112 _reserve1

    ) private returns (uint256 fee0, uint256 fee1) {

        uint256 priceBefore0 = uint256(

            UQ112x112.encode(_reserve1).uqdiv(_reserve0)

        );

        uint256 priceAfter0 = uint256(

            UQ112x112.encode(uint112(balance1)).uqdiv(uint112(balance0))

        );

        uint32[8] memory _vars = vars;

        {

            // check transaction dump range

            require(

                (priceAfter0 * 10000) / priceBefore0 >=

                    (uint256(10000).sub(_vars[uint256(Vars.maxTxDump0)])) &&

                    (priceBefore0 * 10000) / priceAfter0 >=

                    (uint256(10000).sub(_vars[uint256(Vars.maxTxDump1)])),

                "Slippage out of range"

            );

            // update base line price

            uint256 _baseLinePrice0 = block.timestamp /

                _vars[uint256(Vars.timeFrame)]; // reuse variable

            if (_baseLinePrice0 != lastPeriodCounter) {

                //new time frame

                lastPeriodCounter = _baseLinePrice0;

                baseLinePrice0 = priceBefore0; // current price

                _baseLinePrice0 = priceBefore0;

            } else {

                _baseLinePrice0 = baseLinePrice0;

            }

            // check time frame dump range



            if (_baseLinePrice0 != 0)

                require(

                    (priceAfter0 * 10000) / _baseLinePrice0 >=

                        (uint256(10000).sub(_vars[uint256(Vars.maxDump0)])) &&

                        (_baseLinePrice0 * 10000) / priceAfter0 >=

                        (uint256(10000).sub(_vars[uint256(Vars.maxDump1)])),

                    "Slippage out of TF range"

                );

        }

        // check floor price

        {

            FloorPrice memory _floorPrice0 = floorPrice0;

            if (_floorPrice0.baseToken == 0) {

                require(

                    priceAfter0 >= priceBefore0 || // allow to buy token0

                        priceAfter0 >= _floorPrice0.floorPrice0, // or token0 price should be not less than floor price

                    "Price bellow floor"

                );

            } else if (_floorPrice0.baseToken == 1) {

                require(

                    priceAfter0 <= priceBefore0 || // allow to buy token1

                        priceAfter0 <= _floorPrice0.floorPrice0, // or token1 price should be not less than floor price

                    "Price bellow floor"

                );

            }

        }

        {

            // ma = ((periodMA - timeElapsed)*lastMA + lastPrice*timeElapsed) / periodMA

            uint32 timeElapsed = uint32(block.timestamp % 2**32) -

                blockTimestampLast; // overflow is desired

            uint256 ma;

            if (timeElapsed >= _vars[uint256(Vars.periodMA)]) ma = priceBefore0;

            else

                ma =

                    ((_vars[uint256(Vars.periodMA)] - timeElapsed) *

                        lastMA +

                        priceBefore0 *

                        timeElapsed) /

                    _vars[uint256(Vars.periodMA)];

            lastMA = ma;

            fee0 = (priceAfter0 * 10000) / ma;



            // fee should be less than 1

            if (fee0 == 10000) fee0--;

            fee1 = fee0 > 10000

                ? ((9999 - 100000000 / fee0) *

                    _vars[uint256(Vars.coefficient)]) / 10000

                : _vars[uint256(Vars.minimalFee)];

            fee0 = fee0 < 10000

                ? ((9999 - fee0) * _vars[uint256(Vars.coefficient)]) / 10000

                : _vars[uint256(Vars.minimalFee)];

            if (fee1 < _vars[uint256(Vars.minimalFee)])

                fee1 = _vars[uint256(Vars.minimalFee)];

            if (fee0 < _vars[uint256(Vars.minimalFee)])

                fee0 = _vars[uint256(Vars.minimalFee)];

        }

    }



    function _getDenominator(uint256 v)

        internal

        pure

        returns (uint256 denominator)

    {

        if (v > 1e54) denominator = 1e27;

        else if (v > 1e36) denominator = 1e18;

        else denominator = 1e9;

    }



    function sqrt(uint256 y) internal pure returns (uint256 z) {

        if (y > 3) {

            z = y;

            uint256 x = y / 2 + 1;

            while (x < z) {

                z = x;

                x = (y / x + x) / 2;

            }

        } else if (y != 0) {

            z = 1;

        }

    }



    // update reserves and, on the first call per block, price accumulators

    function _update(

        uint256 balance0,

        uint256 balance1,

        uint112 _reserve0,

        uint112 _reserve1

    ) private {

        require(

            balance0 <= uint112(-1) && balance1 <= uint112(-1),

            "Dynamic: OVERFLOW"

        );

        uint32 blockTimestamp = uint32(block.timestamp % 2**32);

        uint32 timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired

        if (timeElapsed > 0 && _reserve0 != 0 && _reserve1 != 0) {

            // * never overflows, and + overflow is desired

            price0CumulativeLast +=

                uint256(UQ112x112.encode(_reserve1).uqdiv(_reserve0)) *

                timeElapsed;

            price1CumulativeLast +=

                uint256(UQ112x112.encode(_reserve0).uqdiv(_reserve1)) *

                timeElapsed;

        }

        reserve0 = uint112(balance0);

        reserve1 = uint112(balance1);

        blockTimestampLast = blockTimestamp;

        emit Sync(reserve0, reserve1);

    }



    /*

    // if fee is on, mint liquidity equivalent to 1/6th of the growth in sqrt(k)

    function _mintFee(uint112 _reserve0, uint112 _reserve1) private returns (bool feeOn) {

        address feeTo = IDynamicFactory(factory).feeTo();

        feeOn = feeTo != address(0);

        uint _kLast = kLast; // gas savings

        if (feeOn) {

            if (_kLast != 0) {

                uint rootK = Math.sqrt(uint(_reserve0).mul(_reserve1));

                uint rootKLast = Math.sqrt(_kLast);

                if (rootK > rootKLast) {

                    uint numerator = totalSupply.mul(rootK.sub(rootKLast));

                    uint denominator = rootK.mul(5).add(rootKLast);

                    uint liquidity = numerator / denominator;

                    if (liquidity > 0) _mint(feeTo, liquidity);

                }

            }

        } else if (_kLast != 0) {

            kLast = 0;

        }

    }

*/

    // this low-level function should be called from a contract which performs important safety checks

    function mint(address to) external lock returns (uint256 liquidity) {

        (uint112 _reserve0, uint112 _reserve1, ) = getReserves(); // gas savings

        uint256 balance0 = IERC20(token0).balanceOf(address(this));

        uint256 balance1 = IERC20(token1).balanceOf(address(this));

        uint256 amount0 = balance0.sub(_reserve0);

        uint256 amount1 = balance1.sub(_reserve1);



        //bool feeOn = _mintFee(_reserve0, _reserve1);

        uint256 _totalSupply = totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee

        if (_totalSupply == 0) {

            uint256 priceBefore0 = uint256(

                UQ112x112.encode(uint112(balance1)).uqdiv(uint112(balance0))

            );

            lastMA = priceBefore0;

            baseLinePrice0 = priceBefore0;

            if (floorPrice0.baseToken != 2)

                floorPrice0.floorPrice0 = uint224(priceBefore0); // set floor price (balance1/balance0)

            liquidity = Math.sqrt(amount0.mul(amount1)).sub(MINIMUM_LIQUIDITY);

            _mint(address(0), MINIMUM_LIQUIDITY); // permanently lock the first MINIMUM_LIQUIDITY tokens

            creationBlock = block.number; // protection from forking pool using flash loan

        } else {

            require(!isPrivate || balanceOf[to] != 0, "Private pool");

            liquidity = Math.min(

                amount0.mul(_totalSupply) / _reserve0,

                amount1.mul(_totalSupply) / _reserve1

            );

        }

        require(liquidity > 0, "Dynamic: INSUFFICIENT_LIQUIDITY_MINTED");

        uint256 last = block.timestamp / vars[uint256(Vars.timeFrame)];

        if (last != lastPeriodCounter) {

            //new time frame

            baseLineLP = totalSupply;

            lastPeriodCounter = last;

        }

        _mint(to, liquidity);

        _update(balance0, balance1, _reserve0, _reserve1);

        //if (feeOn) kLast = uint(reserve0).mul(reserve1); // reserve0 and reserve1 are up-to-date

        emit Mint(msg.sender, amount0, amount1);

    }



    // burn msg.sender LP tokens (use in case pool is not active and LP can't be removed form router)

    function burnLP(uint256 value) external {

        _transfer(msg.sender, address(this), value);

        burn(msg.sender);

    }



    // this low-level function should be called from a contract which performs important safety checks

    function burn(address to)

        public

        lock

        returns (uint256 amount0, uint256 amount1)

    {

        require(creationBlock != block.number); // protection from fork using flash loan

        (uint112 _reserve0, uint112 _reserve1, ) = getReserves(); // gas savings

        address _token0 = token0; // gas savings

        address _token1 = token1; // gas savings

        uint256 balance0 = IERC20(_token0).balanceOf(address(this));

        uint256 balance1 = IERC20(_token1).balanceOf(address(this));

        uint256 liquidity = balanceOf[address(this)];

        //bool feeOn = _mintFee(_reserve0, _reserve1);

        uint256 _totalSupply = totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee

        uint32[8] memory _vars = vars;

        uint256 last = block.timestamp / _vars[uint256(Vars.timeFrame)];

        if (last != lastPeriodCounter) {

            //new time frame

            baseLineLP = totalSupply;

            lastPeriodCounter = last;

        }

        // select lowest slippage (maxTxDump) per transaction

        _vars[uint256(Vars.maxTxDump0)] = _vars[uint256(Vars.maxTxDump0)] <

            _vars[uint256(Vars.maxTxDump1)]

            ? _vars[uint256(Vars.maxTxDump0)]

            : _vars[uint256(Vars.maxTxDump1)];

        require(

            (baseLineLP * 10000) / (_totalSupply - liquidity) >=

                (10000 - _vars[uint256(Vars.maxTxDump0)]),

            "TX limit exceeded"

        );

        // select lowest slippage (maxDump) per per day

        _vars[uint256(Vars.maxDump0)] = _vars[uint256(Vars.maxDump0)] <

            _vars[uint256(Vars.maxDump1)]

            ? _vars[uint256(Vars.maxDump0)]

            : _vars[uint256(Vars.maxDump1)];

        require(

            (baseLineLP * 10000) / (_totalSupply - liquidity) >=

                (10000 - _vars[uint256(Vars.maxDump0)]),

            "Day limit exceeded"

        );



        amount0 = liquidity.mul(balance0) / _totalSupply; // using balances ensures pro-rata distribution

        amount1 = liquidity.mul(balance1) / _totalSupply; // using balances ensures pro-rata distribution

        require(

            amount0 > 0 && amount1 > 0,

            "Dynamic: INSUFFICIENT_LIQUIDITY_BURNED"

        );

        _burn(address(this), liquidity);

        _safeTransfer(_token0, to, amount0);

        _safeTransfer(_token1, to, amount1);

        balance0 = IERC20(_token0).balanceOf(address(this));

        balance1 = IERC20(_token1).balanceOf(address(this));



        _update(balance0, balance1, _reserve0, _reserve1);

        //if (feeOn) kLast = uint(reserve0).mul(reserve1); // reserve0 and reserve1 are up-to-date

        emit Burn(msg.sender, amount0, amount1, to);

    }



    // this low-level function should be called from a contract which performs important safety checks

    function swap(

        uint256 amount0Out,

        uint256 amount1Out,

        address to,

        bytes calldata data

    ) external lock {

        require(

            amount0Out > 0 || amount1Out > 0,

            "Dynamic: INSUFFICIENT_OUTPUT_AMOUNT"

        );

        (uint112 _reserve0, uint112 _reserve1, ) = getReserves(); // gas savings

        require(

            amount0Out < _reserve0 && amount1Out < _reserve1,

            "Dynamic: INSUFFICIENT_LIQUIDITY"

        );



        uint256 balance0;

        uint256 balance1;

        {

            // scope for _token{0,1}, avoids stack too deep errors

            address _token0 = token0;

            address _token1 = token1;

            require(to != _token0 && to != _token1, "Dynamic: INVALID_TO");

            if (amount0Out > 0) _safeTransfer(_token0, to, amount0Out); // optimistically transfer tokens

            if (amount1Out > 0) _safeTransfer(_token1, to, amount1Out); // optimistically transfer tokens

            if (data.length > 0)

                IDynamicCallee(to).DynamicCall(

                    msg.sender,

                    amount0Out,

                    amount1Out,

                    data

                );

            balance0 = IERC20(_token0).balanceOf(address(this));

            balance1 = IERC20(_token1).balanceOf(address(this));

        }

        uint256 amount0In = balance0 > _reserve0 - amount0Out

            ? balance0 - (_reserve0 - amount0Out)

            : 0;

        uint256 amount1In = balance1 > _reserve1 - amount1Out

            ? balance1 - (_reserve1 - amount1Out)

            : 0;

        require(

            amount0In > 0 || amount1In > 0,

            "Dynamic: INSUFFICIENT_INPUT_AMOUNT"

        );

        emit Swap(msg.sender, amount0In, amount1In, amount0Out, amount1Out, to);

        {

            uint256 tax;

            address pairToken;

            address taxReceiver;

            //get token transfer tax

            if (token0 == taxToken.token) {

                if (amount0In == 0) {

                    //buy token

                    tax = amount1In * taxToken.buyTax / 10000;

                    taxReceiver = taxToken.buyTaxReceiver;

                    amount1In = amount1In.sub(tax);

                } else {

                    // sell token

                    tax = amount1Out * 10000 / (10000 - taxToken.sellTax);

                    taxReceiver = taxToken.sellTaxReceiver;

                }

                pairToken = token1;

                balance1 = balance1.sub(tax);

            } else if (token1 == taxToken.token) {

                if (amount1In == 0) {

                    //buy token

                    tax = amount0In * taxToken.buyTax / 10000;

                    taxReceiver = taxToken.buyTaxReceiver;

                    amount0In = amount0In.sub(tax);

                } else {

                    // sell token

                    tax = amount0Out * 10000 / (10000 - taxToken.sellTax);

                    taxReceiver = taxToken.sellTaxReceiver;

                }

                pairToken = token0;

                balance0 = balance0.sub(tax);

            }

            if (tax != 0) _safeTransfer(pairToken, taxReceiver, tax); // transfer tax

        }

        {

            // scope for reserve{0,1}Adjusted, avoids stack too deep errors

            uint256 fee0;

            uint256 fee1;

            address _token0 = token0;

            address _token1 = token1;

            if (to != factory) {

                // avoid endless loop of fee swapping

                (fee0, fee1) = _getFeeAndDumpProtection(

                    balance0,

                    balance1,

                    _reserve0,

                    _reserve1

                );

                if (amount0In != 0) {

                    fee1 = amount0In.mul(fee0) / 10000; // fee by calculation

                    fee0 = balance0.sub(

                        (uint256(_reserve0) * uint256(_reserve1)) / balance1 + 1

                    );

                    require(fee0 >= fee1, "fee0 lower");

                    if (_token0 == IDynamicFactory(factory).WETH()) {

                        fee1 = 0; // take fee in token0 (tokenIn)

                    } else {

                        //take fee in token1 (tokenOut) by default

                        fee1 = balance1.sub(

                            (uint256(_reserve0) * uint256(_reserve1)) /

                                balance0 +

                                1

                        );

                        fee0 = 0;

                    }

                } else if (amount1In != 0) {

                    fee0 = amount1In.mul(fee1) / 10000; // fee by calculation

                    fee1 = balance1.sub(

                        (uint256(_reserve0) * uint256(_reserve1)) / balance0 + 1

                    );

                    require(fee1 >= fee0, "fee1 lower");

                    if (_token1 == IDynamicFactory(factory).WETH()) {

                        fee0 = 0; // take fee in token1 (tokenIn)

                    } else {

                        //take fee in token0 (tokenOut) by default

                        fee0 = balance0.sub(

                            (uint256(_reserve0) * uint256(_reserve1)) /

                                balance1 +

                                1

                        );

                        fee1 = 0;

                    }

                }

                if (fee0 > 0) IERC20(_token0).approve(factory, fee0);

                if (fee1 > 0) IERC20(_token1).approve(factory, fee1);

                IDynamicFactory(factory).swapFee(_token0, _token1, fee0, fee1);

            }

            //uint balance0Adjusted = balance0.mul(1000).sub(amount0In.mul(3));

            //uint balance1Adjusted = balance1.mul(1000).sub(amount1In.mul(3));

            require(

                (balance0.sub(fee0)).mul(balance1.sub(fee1)) >=

                    uint256(_reserve0).mul(_reserve1),

                "Dynamic: K"

            );

            //_update(IERC20(_token0).balanceOf(address(this)), IERC20(_token1).balanceOf(address(this)), _reserve0, _reserve1);

            if (fee0 > 0) balance0 = IERC20(_token0).balanceOf(address(this));

            if (fee1 > 0) balance1 = IERC20(_token1).balanceOf(address(this));

        }

        _update(balance0, balance1, _reserve0, _reserve1);

    }



    // force balances to match reserves

    function skim(address to) external lock {

        address _token0 = token0; // gas savings

        address _token1 = token1; // gas savings

        _safeTransfer(

            _token0,

            to,

            IERC20(_token0).balanceOf(address(this)).sub(reserve0)

        );

        _safeTransfer(

            _token1,

            to,

            IERC20(_token1).balanceOf(address(this)).sub(reserve1)

        );

    }



    // force reserves to match balances

    function sync() external lock {

        _update(

            IERC20(token0).balanceOf(address(this)),

            IERC20(token1).balanceOf(address(this)),

            reserve0,

            reserve1

        );

    }



    function setVars(uint256 varId, uint32 value) external onlyVoting {

        require(varId < vars.length, "varID!");

        if (varId == uint256(Vars.timeFrame) || varId == uint256(Vars.periodMA))

            require(value != 0, "time frame!");

        else require(value <= 10000, "percentage!");

        vars[varId] = value;

    }



    // private/public pool switching (just for pools )

    function switchToPublic() external onlyVoting {

        require(isPrivate == true);

        isPrivate = false;

    }



    // set token tax by token owner

    // token - token that has tax (address(0) if no tax)

    // buyTaxReceiver - address that receive buy tax

    // buyTax - tax when buy "token" (in percentage with 2 decimals)

    // sellTaxReceiver - address that receive sell tax

    // sellTax - tax when sell "token" (in percentage with 2 decimals)

    function setTokenTax(address token, address buyTaxReceiver, uint256 buyTax, address sellTaxReceiver, uint256 sellTax) external {

        address pairToken;

        if (token == token0) {

            pairToken = token1;

        } else if (token == token1) {

            pairToken = token0;

        } else {

            revert(); // wrong token

        }

        // token MUST be ownable

        require(Ownable(token).owner() == msg.sender);

        // pair toke MUST NOT be ownable

        require(safeHasOwner(pairToken) == false);

        require(buyTax < 10000 && sellTax < 10000); // tax must be less than 100.00%

        taxToken = TaxToken(token, buyTaxReceiver, buyTax, sellTaxReceiver, sellTax);

    }



    // return true if contract has owner, otherwise false

    function safeHasOwner(address token) internal returns(bool) {

        (bool success, bytes memory data) = token.call(

            abi.encodeWithSelector(0x8da5cb5b) //bytes4(keccak256(bytes("owner()")));

        );

        if (success && data.length != 0) return true;

        return false;

    }

}