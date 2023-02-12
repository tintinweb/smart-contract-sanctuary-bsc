/**
 *Submitted for verification at BscScan.com on 2023-02-11
*/

// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity >=0.4.0;


/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() {}

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


pragma solidity >=0.4.0;


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
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender) external view returns (uint256);

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



interface IRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function swapExactETHForTokens(
        uint amountOutMin, 
        address[] calldata path, 
        address to, uint deadline
    ) external payable returns (uint[] memory amounts);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IRouter02 is IRouter01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}


// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}


/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}


contract GameFeed is Ownable {

        struct Game {
            string name; // Match Name (e.g Major Katowice, Final, Fnatic vs LDLC
            string t1; // Who is Team 1
            string t2; // Who is Team 2
            uint256 thetime; // starting time
            uint256 result;   // 1 team1wins, 2 team2wins, 3draw, 4 something went wrong ,0 even did not occur
        }

        mapping(uint256 => Game) public games; // 1 team1wins, 2 team2wins, 3draw, 0 even did not occur


        event CreateGame(uint256 indexed time, uint256 indexed id, string name, string t1, string t2);
        event AddResult(uint256 indexed id, uint256 result);
        event ChangeTime(uint256 indexed id, uint256 time);


        uint256 public id = 0;

        function addGameToList(string memory name, uint256 time, string memory t1, string memory t2) public onlyOwner {
            require(games[id].thetime == 0, 'game already added');
            games[id].thetime =  time;
            games[id].name = name;
            games[id].t1 = t1; 
            games[id].t2 = t2;
            emit CreateGame(time, id, name, t1,t2);
            id += 1;
        }

        function addResult(uint256 _id, uint256 result) public onlyOwner {
            require(games[_id].result == 0, 'result already added');
            require(_id < id, 'bad id result');
            games[_id].result = result; 
            emit AddResult(_id, result);
        }

        function modifyTime(uint256 _id, uint256 _time) public onlyOwner {
            require(games[_id].result == 0, 'result already added');
            require(games[_id].thetime > block.timestamp, 'cannot modify other games');
            require(_time > games[_id].thetime, 'time does not require updated');
            games[_id].thetime = _time;
            emit ChangeTime(_id, _time);
        }

}


contract CsgoLounge is Ownable, ReentrancyGuard {

    

    mapping(uint256 => uint256) public t1raise;  // raise by game round
    mapping(uint256 => uint256) public t2raise;  // raise by game round

    mapping(address => mapping(uint256 => uint256)) public contributionsT1; // tracks personal contributions in BUSD
    mapping(address => mapping(uint256 => uint256)) public contributionsT2; // tracks personal contributions in BUSD
    mapping(address => mapping(uint256 => bool)) public withdrewFunds; 

    uint256 public constant MULTIPLIER = 10e18;
    bool public takeFees = false;
    uint256 public fee = 500; // 5%

    IBEP20 public busd;
    GameFeed public gameOracle;
    IRouter02 public router =  IRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    


    constructor(IBEP20 _busd, GameFeed _oracle) {
        busd = _busd;
        gameOracle = _oracle;
    }

    event Bet(address user, uint256 amount, uint256 id);
    event ChangeFee(uint256 fee);

    function changeFee(uint256 _fee) public onlyOwner {
        require(_fee < 1000, 'fee larger than 10%');
        fee = _fee; 
        emit ChangeFee(_fee);
    }

    function enableFee() public onlyOwner {
        takeFees = !takeFees;
    }


    function calculateFee(uint256 _amount) public view returns(uint256) {
        uint256 _fee = _amount * fee / 10000;
        return _fee;
    }
    

    function getOracleData(uint256 id) public view returns(string memory, uint256 ,uint256, uint256){

        (string memory name, ,, uint256 thetime, uint256 result) = gameOracle.games(id);
        uint256 currentId = gameOracle.id();
        return(name, thetime, result, currentId);
    }


    // bet t1 via bnb
    function betT1(uint256 id, uint256 _amountMin) public payable {
        
        (,uint256 thetime, uint256 result, uint256 currentId) = getOracleData(id);

        require(result == 0 && id <= currentId, 'has already played or is inexistent');
        require(block.timestamp <= thetime, 'match already live');

        require(msg.value > 0, 'incorrect message value');
        require(_amountMin > 0, 'incorrect amount');

        // swap ETH to busd
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(busd);
        uint balanceBefore = busd.balanceOf(address(this));
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value:msg.value}(_amountMin,path, address(this), block.timestamp);
        uint balanceAfter = busd.balanceOf(address(this));
        uint256 difference = balanceAfter - balanceBefore;
        require(difference > 0, 'bad swap, try higher amounts');

        // store bet amounts inside smart contract
        t1raise[id] = t1raise[id]+difference;
        contributionsT1[msg.sender][id] += difference;
        emit Bet(msg.sender, difference, id);
    }


    // bet t2 via bnb
    function betT2(uint256 id, uint256 _amountMin) public payable {
        (,uint256 thetime, uint256 result, uint256 currentId) = getOracleData(id);

        require(result == 0 && id <= currentId, 'has already played or is inexistent');
        require(block.timestamp <= thetime, 'match already live');

        require(msg.value > 0, 'incorrect message value');

        // swap ETH to busd
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(busd);
        uint balanceBefore = busd.balanceOf(address(this));
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value:msg.value}(_amountMin,path, address(this), block.timestamp);
        uint balanceAfter = busd.balanceOf(address(this));
        uint256 difference = balanceAfter - balanceBefore;
        require(difference > 0, 'bad swap, try higher amounts');
        
        // store bet amounts inside smart contract
        t2raise[id] = t2raise[id]+difference;
        contributionsT2[msg.sender][id] += difference;
        emit Bet(msg.sender, difference, id);
    }


    function betT1Token(uint256 id, uint256 amount) public {
        (,uint256 thetime, uint256 result, uint256 currentId) = getOracleData(id);

        require(result == 0 && id <= currentId, 'has already played or is inexistent');
        require(block.timestamp <= thetime, 'match already live');
        require(amount > 0, 'bad amount');
        TransferHelper.safeTransferFrom(address(busd), msg.sender, address(this), amount);

        // store bet amounts inside smart contract
        t1raise[id] = t1raise[id]+amount;
        contributionsT1[msg.sender][id] += amount;
        emit Bet(msg.sender, amount, id);
    }

    function betT1TokenForSomeone(uint256 id, uint256 amount, address who) public {
        require(who != address(0x0), 'bad someone address');
        (,uint256 thetime, uint256 result, uint256 currentId) = getOracleData(id);

        require(result == 0 && id <= currentId, 'has already played or is inexistent');
        require(block.timestamp <= thetime, 'match already live');
        require(amount > 0, 'bad amount');
        TransferHelper.safeTransferFrom(address(busd), msg.sender, address(this), amount);

        // store bet amounts inside smart contract
        t1raise[id] = t1raise[id]+amount;
        contributionsT1[who][id] += amount;
        emit Bet(who, amount, id);
    }


    function betT2Token(uint256 id, uint256 amount) public {
        (,uint256 thetime, uint256 result, uint256 currentId) = getOracleData(id);

        require(result == 0 && id <= currentId, 'has already played or is inexistent');
        require(block.timestamp <= thetime, 'match already live');
        require(amount > 0, 'bad amount');
        TransferHelper.safeTransferFrom(address(busd), msg.sender, address(this), amount);


        // store bet amounts inside smart contract
        t2raise[id] = t2raise[id]+amount;
        contributionsT2[msg.sender][id] += amount;
        emit Bet(msg.sender, amount, id);
    }


    function betT2TokenForSomeone(uint256 id, uint256 amount, address who) public {
        (,uint256 thetime, uint256 result, uint256 currentId) = getOracleData(id);

        require(result == 0 && id <= currentId, 'has already played or is inexistent');
        require(block.timestamp <= thetime, 'match already live');
        require(amount > 0, 'bad amount');
        TransferHelper.safeTransferFrom(address(busd), msg.sender, address(this), amount);


        // store bet amounts inside smart contract
        t2raise[id] = t2raise[id]+amount;
        contributionsT2[who][id] += amount;
        emit Bet(who, amount, id);
    }


    function withdrawFunds(uint256 _id) public nonReentrant {
        require(withdrewFunds[msg.sender][_id] == false, 'already withdrew earnings');
        (,,uint256 result,) = getOracleData(_id);
        require(result != 0, 'has not been chosen');
        //  1 team1wins, 2 team2wins, 3draw, 4 something went wrong ,0 even did not occur
        if(result == 1){
            // team 1 wins
            require(contributionsT1[msg.sender][_id] > 0, 'no contributions in this round');
            uint256 payoutAmount = fetchPayouts(_id);
            if(takeFees == true){
              uint256 earned =  (contributionsT1[msg.sender][_id] * payoutAmount / MULTIPLIER);
              uint256 theFee = calculateFee(earned);
              uint256 toPay =  contributionsT1[msg.sender][_id]+ (contributionsT1[msg.sender][_id] * payoutAmount / MULTIPLIER) - theFee;
              TransferHelper.safeTransfer(address(busd), owner(), theFee);
              TransferHelper.safeTransfer(address(busd), msg.sender, toPay);
              withdrewFunds[msg.sender][_id] = true;
            } else {
                uint256 toPay =  contributionsT1[msg.sender][_id]+ (contributionsT1[msg.sender][_id] * payoutAmount / MULTIPLIER);
                TransferHelper.safeTransfer(address(busd), msg.sender, toPay);
                withdrewFunds[msg.sender][_id] = true;
            }

        } else {
            if(result == 2){
                // team 2 wins 
                require(contributionsT2[msg.sender][_id] > 0, 'no contributions in this round');
                uint256 payoutAmount = fetchPayouts(_id);
                if(takeFees == true){
                    uint256 earned =  (contributionsT2[msg.sender][_id] * payoutAmount / MULTIPLIER);
                    uint256 theFee = calculateFee(earned);
                    uint256 toPay =  contributionsT2[msg.sender][_id]+ (contributionsT2[msg.sender][_id] * payoutAmount / MULTIPLIER) - theFee;
                    TransferHelper.safeTransfer(address(busd), owner(), theFee);
                    TransferHelper.safeTransfer(address(busd), msg.sender, toPay);
                    withdrewFunds[msg.sender][_id] = true;
                }else {
                    uint256 toPay =  contributionsT2[msg.sender][_id]+ (contributionsT2[msg.sender][_id] * payoutAmount / MULTIPLIER);
                    TransferHelper.safeTransfer(address(busd), msg.sender, toPay);
                    withdrewFunds[msg.sender][_id] = true;
                }

            } else {
                // result is 3 or 4, there is refund
                TransferHelper.safeTransfer(address(busd), msg.sender, contributionsT1[msg.sender][_id]);
                TransferHelper.safeTransfer(address(busd), msg.sender, contributionsT2[msg.sender][_id]);
                withdrewFunds[msg.sender][_id] = true;
            }
        }
    }


    function fetchPayouts(uint256 _id) public view returns(uint256){
        (,,uint256 result,) = getOracleData(_id);

        require(result > 0, 'no payout');
        uint256 t1contr = t1raise[_id];
        uint256 t2contr = t2raise[_id];

        // divide loser by winner

        if(result == 1){
            uint256 payout = (t2contr*MULTIPLIER) / t1contr; // (100*a)/b
            return payout;
        }else {
            if(result == 2){
                uint256 payout =  (t1contr* MULTIPLIER) / t2contr ;
                return payout;
            } else {
                return 0;
            }
        }
    }



}