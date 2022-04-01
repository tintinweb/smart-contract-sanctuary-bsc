// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import  "./interfaces/IBOX.sol";

contract LuckyDraw1 is Ownable {
    uint256 public constant DAY_IN_SECONDS = 1 days;
    uint256 public WEEK_IN_SECONDS = 7 days;
    uint256 public constant percentDecimal = 10000;
    uint256 public percentToJackpot = 750;
    uint256 public percentToRewardoWeeklyTop = 500;
    uint256 public percentToRewardWeeklyLucky = 250;
    uint256 public percentToTreasury = 3000;
    uint256 public percentToWeeklyLucky = 2500;
    uint256[] public percentToWeeklyTop = [3200,2100,1500,1000,700,500,400,300,200,100];
    uint public jackpotPrize;
    IBOX public immutable box;
    address immutable public MEXIAddress;
    string public commonHash;
    string public epicHash;
    string public legendHash;
    address public treasuryAddress;
    struct Top {
        address[] list;
        uint amount;
    }
    mapping(uint => Top) public top10Winner;
    mapping(uint => Top) public top10Player;
    mapping(uint => Top) public luckyMembers;
    mapping(address => mapping(uint => bool)) public claimTop10Winner; // user -> week -> true / false
    mapping(address => mapping(uint => bool)) public claimTop10Player; // user -> week -> true / false
    mapping(address => mapping(uint => bool)) public claimLuckyMembers; // user -> week -> true / false
    struct Weeklyuser {
        address[] weeklyUsersArr;
        mapping(address => bool) isSpin;
    }

    mapping(uint => Weeklyuser) internal weeklyUsers; // week -> weeklyUsers
    uint public indexTop10Winner;
    uint public indexTop10Player;

    struct Pool {
        uint dailySpin;
        uint price;
        bool isOpen;
    }
    struct User {
        uint totalSpin;
        uint totalWin;
        bool top10Winner;
        bool top10Player;
    }
    Pool[] public pools;
    mapping(address => mapping(uint => User)) public users;
    mapping(address => mapping(uint => uint)) public userSpined; // user => datetime => spined
    mapping(address => uint) public userTotalSpined; // user => spined
    mapping(uint => string) public guaranteedSpin; // spin no => MX BOX hash

    constructor(address _treasuryAddress, IBOX _box, address _MEXIAddress) {
        require(_treasuryAddress != address(0), "LuckyDraw: _treasuryAddress invalid");
        treasuryAddress = _treasuryAddress;
        box = _box;
        MEXIAddress = _MEXIAddress;
        commonHash = "QmePhLUk4ijJW3r74RMyzTLqcxD5UYqsPeoW2rboGQDBWg";
        epicHash = "QmTsdkK9eqSQNo5HNQkpvtjULvaQr8f4zw8dftru3ax4pY";
        legendHash = "QmYr12YhmefGwYY6zruuWkByzCJP4rdDJJhdHYXZfNCR82";
        jackpotPrize = 100_000 ether; // deposit jackpot reward after build contract
        addPool(100, 50_000 ether, 1000, commonHash);
        addPool(100, 100_000 ether, 100, epicHash);
        addPool(100, 250_000 ether, 10, legendHash);
        addPool(1000000, 50_000 ether, 0, '');
    }
    function getweeklyUsersArr(uint _week) external view returns(address[] memory) {
        return weeklyUsers[_week].weeklyUsersArr;
    }
    function claimTopWinner(uint _week) external {
        bool result;
        uint higher;
        (result, higher) = isTopWinner(_week, _msgSender());
        require(result, 'LuckyDraw::claimTopWinner:Not top');
        require(!claimTop10Winner[_msgSender()][_week], 'LuckyDraw::claimTopWinner:Claimed');
        require(getWeek() - _week == 1, 'LuckyDraw::claimTopWinner:Expired');
        uint claimAmount = top10Winner[_week].amount * percentToWeeklyTop[higher] / percentDecimal;
        IERC20(MEXIAddress).transfer(_msgSender(), claimAmount);
        claimTop10Winner[_msgSender()][_week] = true;
    }
    function claimTopPlayer(uint _week) external {
        bool result;
        uint higher;
        (result, higher) = isTopPlayer(_week, _msgSender());
        require(result, 'LuckyDraw::claimTopPlayer:Not top');
        require(!claimTop10Player[_msgSender()][_week], 'LuckyDraw::claimTopPlayer:Claimed');
        require(getWeek() - _week == 1, 'LuckyDraw::claimTopPlayer:Expired');
        uint claimAmount = top10Player[_week].amount * percentToWeeklyTop[higher] / percentDecimal;
        IERC20(MEXIAddress).transfer(_msgSender(), claimAmount);
        claimTop10Player[_msgSender()][_week] = true;
    }
    function claimWeeklyLuckyMembers(uint _week) external {
        require(!claimLuckyMembers[_msgSender()][_week], 'LuckyDraw::claimWeeklyLuckyMembers:Claimed');
        require(getWeek() - _week == 1, 'LuckyDraw::claimWeeklyLuckyMembers:Expired');
        uint claimAmount = luckyMembers[_week].amount * percentToRewardWeeklyLucky / percentDecimal;
        IERC20(MEXIAddress).transfer(_msgSender(), claimAmount);
        claimLuckyMembers[_msgSender()][_week] = true;
    }
    function getTop10Winner(uint _week) external view returns(address[] memory list, uint amount) {
        return (top10Winner[_week].list, top10Winner[_week].amount);
    }
    function getTop10Player(uint _week) external view returns(address[] memory list, uint amount) {
        return (top10Player[_week].list, top10Player[_week].amount);
    }
    function getLuckyMembers(uint _week) external view returns(address[] memory list, uint amount) {
        return (luckyMembers[_week].list, top10Player[_week].amount);
    }
    function isTopWinner(uint _week, address _user) public view returns(bool result, uint higher) {
        User memory user = users[_user][_week];
        address[] memory top = top10Winner[_week].list;
        for(uint i = 0; i < top.length; i++) {
            if(user.totalWin < users[top[i]][_week].totalWin) {
                higher += 1;
            }
        }
        for(uint i = 0; i < top.length; i++) {
            if(top[i] == _user) {
                result = true;
                break;
            }
        }
    }
    function isTopPlayer(uint _week, address _user) public view returns(bool result, uint higher) {
        User memory user = users[_user][_week];
        address[] memory top = top10Winner[_week].list;
        for(uint i = 0; i < top.length; i++) {
            if(user.totalSpin < users[top[i]][_week].totalSpin) {
                higher += 1;
            }
        }
        for(uint i = 0; i < top.length; i++) {
            if(top[i] == _user) {
                result = true;
                break;
            }
        }
    }
    function resetIndexWinner(uint _week) internal {
        address[] memory _top10Winner = top10Winner[_week].list;
        uint smallest = users[_top10Winner[indexTop10Winner]][_week].totalWin;
        for(uint i = 0; i < 10; i++) {
            if(smallest > users[_top10Winner[i]][_week].totalWin) {
                smallest = users[_top10Winner[i]][_week].totalWin;
                indexTop10Winner = i;
            }
        }
    }
    function resetIndexPlayer(uint _week) internal {
        address[] memory _top10Player = top10Player[_week].list;
        uint smallest = users[_top10Player[indexTop10Player]][_week].totalSpin;
        for(uint i = 0; i < 10; i++) {
            if(smallest > users[_top10Player[i]][_week].totalSpin) {
                smallest = users[_top10Player[i]][_week].totalSpin;
                indexTop10Player = i;
            }
        }
    }
    function setTop10Winner(uint _winMEXIAmount, uint _week) internal {

        users[msg.sender][_week].totalWin += _winMEXIAmount;
        Top storage _top10Winner = top10Winner[_week];
        if(!users[msg.sender][_week].top10Winner) {
            if(_top10Winner.list.length < 10) {
                _top10Winner.list.push(msg.sender);
                users[msg.sender][_week].top10Winner = true;
            } else {
                if(users[msg.sender][_week].totalWin > users[_top10Winner.list[indexTop10Winner]][_week].totalWin) {
                    users[_top10Winner.list[indexTop10Winner]][_week].top10Winner = false;
                    _top10Winner.list[indexTop10Winner] = msg.sender;
                    users[msg.sender][_week].top10Winner = true;
                    resetIndexWinner(_week);
                }
            }
        }
    }
    function setTop10Player(uint _betAmount, uint _week) internal {
        users[msg.sender][_week].totalSpin += _betAmount;
        Top storage _top10Player = top10Player[_week];
        if(!users[msg.sender][_week].top10Player) {
            if(_top10Player.list.length < 10) {
                _top10Player.list.push(msg.sender);
                users[msg.sender][_week].top10Player = true;
            } else {
                if(users[msg.sender][_week].totalSpin > users[_top10Player.list[indexTop10Player]][_week].totalSpin) {
                    users[_top10Player.list[indexTop10Player]][_week].top10Player = false;
                    _top10Player.list[indexTop10Player] = msg.sender;
                    users[msg.sender][_week].top10Player = true;
                    resetIndexPlayer(_week);
                }
            }
        }
    }
    function getDate() public view returns (uint256) {
        return block.timestamp / DAY_IN_SECONDS;
    }
    function getWeek() public view returns (uint256) {
        return block.timestamp / WEEK_IN_SECONDS;
    }
    function _resetJackpot() internal {
        jackpotPrize = 100_000 ether;
        require(IERC20(MEXIAddress).transferFrom(treasuryAddress, address(this), jackpotPrize));
    }
    function _takeJackpot() internal {
        require(IERC20(MEXIAddress).transfer(_msgSender(), jackpotPrize));
        _resetJackpot();
    }
    function _handleSpinFee(uint _pid, uint _week) internal {
        Pool memory _p = pools[_pid];
        uint toTreasury = _p.price * percentToTreasury / percentDecimal;
        uint toTop = _p.price * percentToRewardoWeeklyTop / percentDecimal;
        uint toLucky = _p.price * percentToRewardWeeklyLucky / percentDecimal;
        require(IERC20(MEXIAddress).transferFrom(_msgSender(), address(this), _p.price - percentToTreasury));
        jackpotPrize += _p.price * percentToJackpot / percentDecimal;
        top10Player[_week].amount += toTop;
        top10Winner[_week].amount += toTop;
        luckyMembers[_week].amount += toLucky;
        require(IERC20(MEXIAddress).transferFrom(_msgSender(), treasuryAddress, toTreasury));
        setTop10Player(_p.price, _week);
    }
    function random(uint nonce) public view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, nonce)))%percentDecimal;
    }

    function randomLuckyMem(uint _week) external onlyOwner {
        require(_week < getWeek() && luckyMembers[_week].list.length == 0, "LuckyDraw::randomLuckyMem:existed");
        uint n = weeklyUsers[_week].weeklyUsersArr.length;

        for(uint i = 0; i < 5; i++) {
            luckyMembers[_week].list.push(weeklyUsers[_week].weeklyUsersArr[uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, n-i)))%n]);
        }
    }

    function _handleTop10Winner(uint _winMEXIAmount) internal {
        uint _week = getWeek();
        if(_winMEXIAmount > 0) {
            IERC20(MEXIAddress).transfer(_msgSender(), _winMEXIAmount);
            users[msg.sender][_week].totalWin + _winMEXIAmount;
            setTop10Winner(_winMEXIAmount, _week);
        }
    }
    function _spinCommon(uint pickRandom) internal {
        if(pickRandom < 5) {
            uint _tokenId = box.currentTokenId() + 1;
            box.mint(_msgSender(), _tokenId, commonHash);
        }
        uint winMEXIAmount;
        if(pickRandom >= 5 && pickRandom < 105) winMEXIAmount = 500_000 ether;
        if(pickRandom >= 105 && pickRandom < 505) winMEXIAmount = 150_000 ether;
        if(pickRandom >= 505 && pickRandom < 2000) winMEXIAmount = 75_000 ether;
        if(pickRandom >= 2000 && pickRandom < 3000) winMEXIAmount = 7_500 ether;
        if(pickRandom >= 3000 && pickRandom < 5000) winMEXIAmount = 5_000 ether;
        if(pickRandom >= 5000 && pickRandom < 10000) winMEXIAmount = 2_500 ether;
        _handleTop10Winner(winMEXIAmount);
    }
    function _spinEpic(uint pickRandom) internal {

        if(pickRandom < 3) {
            uint _tokenId = box.currentTokenId() + 1;
            box.mint(_msgSender(), _tokenId, epicHash);
        }
        uint winMEXIAmount;
        if(pickRandom >= 3 && pickRandom < 103) winMEXIAmount = 1000_000 ether;
        if(pickRandom >= 103 && pickRandom < 503) winMEXIAmount = 300_000 ether;
        if(pickRandom >= 503 && pickRandom < 2000) winMEXIAmount = 150_000 ether;
        if(pickRandom >= 2000 && pickRandom < 3000) winMEXIAmount = 15_000 ether;
        if(pickRandom >= 3000 && pickRandom < 5000) winMEXIAmount = 10_000 ether;
        if(pickRandom >= 5000 && pickRandom < 10000) winMEXIAmount = 5000 ether;
        _handleTop10Winner(winMEXIAmount);
    }
    function _spinLegendary(uint pickRandom) internal {
        if(pickRandom == 0) {
            uint _tokenId = box.currentTokenId() + 1;
            box.mint(_msgSender(), _tokenId, legendHash);
        }
        uint winMEXIAmount;
        if(pickRandom >= 1 && pickRandom < 101) winMEXIAmount = 2500_000 ether;
        if(pickRandom >= 101 && pickRandom < 501) winMEXIAmount = 750_000 ether;
        if(pickRandom >= 501 && pickRandom < 2000) winMEXIAmount = 375_000 ether;
        if(pickRandom >= 2000 && pickRandom < 3000) winMEXIAmount = 37_500 ether;
        if(pickRandom >= 3000 && pickRandom < 5000) winMEXIAmount = 25_000 ether;
        if(pickRandom >= 5000 && pickRandom < 10000) winMEXIAmount = 12_500 ether;
        _handleTop10Winner(winMEXIAmount);
    }
    function _spinJackpot(uint pickRandom) internal {
        if(pickRandom == 0) _takeJackpot();
        uint winMEXIAmount;
        if(pickRandom >= 1 && pickRandom < 101) winMEXIAmount = 500_000 ether;
        if(pickRandom >= 101 && pickRandom < 501) winMEXIAmount = 150_000 ether;
        if(pickRandom >= 501 && pickRandom < 2000) winMEXIAmount = 75_000 ether;
        if(pickRandom >= 2000 && pickRandom < 3000) winMEXIAmount = 7_500 ether;
        if(pickRandom >= 3000 && pickRandom < 5000) winMEXIAmount = 5_000 ether;
        if(pickRandom >= 5000 && pickRandom < 10000) winMEXIAmount = 2_500 ether;
        _handleTop10Winner(winMEXIAmount);
    }
    function _takeGuaranteedSpin(string memory _hash) internal {
        uint _tokenId = box.currentTokenId() + 1;
        box.mint(_msgSender(), _tokenId, _hash);
    }
    function _spin(uint _pid, uint nonce) internal {
        uint pickRandom = random(nonce);
        if(_pid == 0) _spinCommon(pickRandom);
        if(_pid == 1) _spinEpic(pickRandom);
        if(_pid == 2) _spinLegendary(pickRandom);
        if(_pid == 3) _spinJackpot(pickRandom);
        if(_pid < 3) {
            userTotalSpined[_msgSender()]++;
            if(keccak256(abi.encodePacked(guaranteedSpin[userTotalSpined[_msgSender()]])) != keccak256(abi.encodePacked(''))) _takeGuaranteedSpin(guaranteedSpin[userTotalSpined[_msgSender()]]);
        }
    }
    function spins(uint _pid, uint n, uint nonce) external {
        for(uint i = 0; i < n; i++) {
            spin(_pid, nonce * (i+1));
        }
    }
    function spin(uint _pid, uint nonce) public {
        Pool memory p = pools[_pid];
        uint _week = getWeek();
        require(MEXIAddress != address(0), "LuckyDraw: _pid is not exist");
        uint256 date = getDate();

        require(userSpined[_msgSender()][date] < p.dailySpin, "LuckyDraw: over spin time");
        if(!weeklyUsers[_week].isSpin[_msgSender()]) {
            weeklyUsers[_week].isSpin[_msgSender()] = true;
            weeklyUsers[_week].weeklyUsersArr.push(_msgSender());
        }
        userSpined[_msgSender()][date]++;
        _handleSpinFee(_pid, _week);
        _spin(_pid, nonce);
    }
    function addPool(uint _dailySpin, uint _price, uint _guaranteedSpin, string memory _hash) public onlyOwner {
        require(_price > 0, "LuckyDraw: _price invalid");
        pools.push(Pool(_dailySpin, _price, true));
        guaranteedSpin[_guaranteedSpin] = _hash;
    }
    function updateTreasury(address _treasuryAddress) external onlyOwner {
        treasuryAddress = _treasuryAddress;
    }
    function updatePool(uint _pid, uint _dailySpin, uint _price, bool _isOpen) external onlyOwner {
        Pool storage p = pools[_pid];
        require(_price > 0, "LuckyDraw: _price invalid");
        require(MEXIAddress != address(0), "LuckyDraw: _pid is not exist");
        p.dailySpin = _dailySpin;
        p.price = _price;
        p.isOpen = _isOpen;
    }
    function inCaseTokensGetStuck(IERC20 _token) external onlyOwner {

        uint amount = _token.balanceOf(address(this));
        _token.transfer(msg.sender, amount);
    }
    function config(uint _WEEK_IN_SECONDS) external onlyOwner {
        WEEK_IN_SECONDS = _WEEK_IN_SECONDS;
    }
    function configPercentTo(uint256 _percentToJackpot, uint256 _percentToRewardoWeeklyTop, uint256 _percentToRewardWeeklyLucky, uint256 _percentToTreasury) external onlyOwner {
        percentToJackpot = _percentToJackpot;
        percentToRewardoWeeklyTop = _percentToRewardoWeeklyTop;
        percentToRewardWeeklyLucky = _percentToRewardWeeklyLucky;
        percentToTreasury = _percentToTreasury;
    }
    function configPercentOut(uint256 _percentToWeeklyLucky, uint256[] memory _percentToWeeklyTop) external onlyOwner {
        percentToWeeklyLucky = _percentToWeeklyLucky;
        percentToWeeklyTop = _percentToWeeklyTop;
    }

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract IBOX {
    function totalSupply() virtual external view returns(uint256);
    function currentTokenId() virtual external view returns(uint256);
    function mint(address _to, uint256 _tokenId, string memory _tokenHash) virtual external;
    function mints(uint n, address _to) virtual external;
    function transferFrom(address _from, address _to, uint256 _tokenId) virtual external;
    function types(uint256 _boxId) virtual external view returns(string memory name, string memory hash, uint256 maxSupply, uint256 remain);
    function balanceOf(address owner) external view virtual returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint index) external view virtual returns (uint256);
    function tokenHash(uint256 tokenId) external view virtual returns (string memory);
}

// SPDX-License-Identifier: MIT

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

pragma solidity ^0.8.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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

// SPDX-License-Identifier: MIT

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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}