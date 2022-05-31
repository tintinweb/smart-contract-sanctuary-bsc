/**
 *Submitted for verification at BscScan.com on 2022-05-31
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library SafeMath {
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

contract Launchpad is Ownable {
    using SafeMath for uint256;
    using Address for address;

    address public thisToken = address(this);
    address public main;
    address public token;
    address public withdrawMainWallet;
    address public withdrawTokenWallet;

    uint256 public presaleRate;
    uint256 public minImum;
    uint256 public maxImum;
    uint256 public minCap;
    uint256 public maxCap;
    uint256 public startTime;
    uint256 public endTime;
    uint256 public finishTime;

    uint256 public fee = 5;
    uint256 public tokenFee = 5;

    State private state;

    enum State {
        Upcoming,
        Inprogress,
        Filled,
        Ended,
        Canceled
    }

    bool public isCompleted;
    bool public useWhitelisting;
    bool public useCX;
    uint256 public CXAmount;
    uint256 public CXRate;
    mapping(address => bool) public whitelistedUsers;
    address[] public whitelisted;
    uint256 public whitelistedNum;
    string public additionalInfo;

    mapping(address => uint256) public contributionAmount;
    mapping(address => bool) public contributionIsClaim;
    mapping(address => bool) public contributionIsRefund;
    address[] public contributionList;
    uint256 public totalContribution;
    uint256 public totalClaimed;
    uint256 public totalRefunded;

    address market = 0x0dAC62360961544132a1283205501f3FcDC9817c;

    event AddMultiWhitelistedUsers(address[] _usersAddresses);
    event RemoveMultiWhitelistedUsers(address[] _usersAddresses);
    event Contribute(address sender, uint256 value);
    event Claim(address recipient, uint256 amount);
    event Cancel();
    event Finalize();

    constructor(
        address _owner,
        address[4] memory _addrs,
        uint256 _rateSetting,
        uint256[2] memory _contributionSettings,
        uint256[2] memory _capSettings,
        uint256[2] memory _timeSettings,
        bool _useWhitelisting,
        string memory _poolDetails
    ) {
        main = _addrs[0];
        token = _addrs[1];
        withdrawMainWallet = _addrs[2];
        withdrawTokenWallet = _addrs[3];
        presaleRate = _rateSetting;
        minImum = _contributionSettings[0];
        maxImum = _contributionSettings[1];
        minCap = _capSettings[0];
        maxCap = _capSettings[1];
        startTime = _timeSettings[0];
        endTime = _timeSettings[1];
        useWhitelisting = _useWhitelisting;
        additionalInfo = _poolDetails;

        state = State.Upcoming;
        transferOwnership(_owner);
    }

    function addMultiWhitelistedUsers(address[] calldata _usersAddresses)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < _usersAddresses.length; i++) {
            if (!whitelistedUsers[_usersAddresses[i]]) {
                whitelistedUsers[_usersAddresses[i]] = true;
                whitelisted.push(_usersAddresses[i]);
                whitelistedNum++;
            }
        }
        emit AddMultiWhitelistedUsers(_usersAddresses);
    }

    function removeMultiWhitelistedUsers(address[] calldata _usersAddresses)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < _usersAddresses.length; i++) {
            if (whitelistedUsers[_usersAddresses[i]]) {
                whitelistedUsers[_usersAddresses[i]] = false;
                for (uint256 j = 0; j < whitelistedNum; j++) {
                    if (whitelisted[j] == _usersAddresses[i]) {
                        whitelisted[j] = whitelisted[whitelistedNum - 1];
                        whitelisted.pop();
                        whitelistedNum--;
                        break;
                    }
                }
            }
        }
        emit RemoveMultiWhitelistedUsers(_usersAddresses);
    }

    function setUseWhitelisting(bool _useWhitelisting) external onlyOwner {
        require(
            useWhitelisting != _useWhitelisting,
            "useWhitelisting is this value"
        );
        useWhitelisting = _useWhitelisting;
    }

    function setCX(bool _useCX, uint8 _CXRate) external payable onlyOwner {
        require(getState() == State.Upcoming, "presale is not Upcoming");
        require(_CXRate <= 10, "rate must <= 10%");
        require(
            msg.value >= maxCap.mul(_CXRate).div(100),
            "amount must >= maxCap*rate"
        );
        require(
            block.timestamp.add(600) <= startTime,
            "must more than ten minutes before start time"
        );
        useCX = _useCX;
        CXRate = _CXRate;
        CXAmount = msg.value;
    }

    function contribute(address _recommend) external payable {
        require(
            msg.value >= minImum &&
                contributionAmount[msg.sender].add(msg.value) <= maxImum,
            "contribution value out of settings"
        );
        require(
            totalContribution.add(msg.value) <= maxCap,
            "value is over maxCap"
        );
        if (useWhitelisting) {
            require(whitelistedUsers[msg.sender], "sender is not in whitelist");
        }
        if (contributionAmount[msg.sender] == 0) {
            contributionList.push(msg.sender);
        }
        contributionAmount[msg.sender] = contributionAmount[msg.sender].add(
            msg.value
        );
        totalContribution = totalContribution.add(msg.value);
        contributionIsClaim[msg.sender] = false;
        if (useCX) {
            uint256 _fee4Recommend = msg.value.mul(CXRate).div(100);
            require(_fee4Recommend <= CXAmount, "CXAmount is not enough");
            CXAmount = CXAmount.sub(_fee4Recommend);
            payable(_recommend).transfer(_fee4Recommend);
        }
        emit Contribute(msg.sender, msg.value);
    }

    function claim() external {
        uint256 amount = contributionAmount[msg.sender].mul(presaleRate);
        if (!contributionIsClaim[msg.sender] && state == State.Ended) {
            IERC20(token).transfer(address(msg.sender), amount);
            contributionIsClaim[msg.sender] = true;
            totalClaimed = totalClaimed.add(amount);
        }
        emit Claim(msg.sender, amount);
    }

    function cancel() external onlyOwner {
        state = State.Canceled;
        emit Cancel();
    }

    function finalize() external onlyOwner {
        uint256 tokenAmount = totalContribution.mul(presaleRate);
        uint256 tokenBalance = IERC20(token).balanceOf(address(this));
        require(tokenBalance >= tokenAmount, "token balance is not enough");
        state = State.Ended;
        finishTime = block.timestamp;
        emit Finalize();
    }

    function contributionerWithdraw(uint256 _amount) external {
        require(_amount <= contributionAmount[msg.sender], "amount is wrong");
        require(getState() == State.Canceled, "presale is not Canceled");
        if (contributionAmount[msg.sender] == _amount) {
            contributionIsRefund[msg.sender] = true;
        }
        contributionAmount[msg.sender] = contributionAmount[msg.sender].sub(
            _amount
        );
        totalRefunded = totalRefunded.add(_amount);
        payable(msg.sender).transfer(_amount);
    }

    function emergencyWithdraw(address _to, uint256 _amount) external payable {
        require(_amount <= contributionAmount[msg.sender], "amount is wrong");
        if (contributionAmount[msg.sender] == _amount) {
            contributionIsRefund[msg.sender] = true;
        }
        contributionAmount[msg.sender] = contributionAmount[msg.sender].sub(
            _amount
        );
        totalRefunded = totalRefunded.add(_amount);
        uint256 feeAmount = _amount.mul(fee).div(100);
        payable(_to).transfer(_amount.sub(feeAmount));
    }

    function emergencyWithdraw(
        address _token,
        address _to,
        uint256 _amount
    ) external payable {
        require(
            _amount <= contributionAmount[msg.sender].mul(presaleRate),
            "amount is wrong"
        );

        contributionAmount[msg.sender] = contributionAmount[msg.sender].sub(
            _amount.div(presaleRate)
        );
        uint256 feeToken = _amount.mul(tokenFee).div(100);
        IERC20(_token).transfer(_to, _amount.sub(feeToken));
    }

    function updateWithdrawAddress(
        address _withdrawMainWallet,
        address _withdrawTokenWallet
    ) external onlyOwner {
        require(
            withdrawMainWallet != _withdrawMainWallet &&
                withdrawTokenWallet != _withdrawTokenWallet,
            "wallet is setted"
        );
        withdrawMainWallet = _withdrawMainWallet;
        withdrawTokenWallet = _withdrawTokenWallet;
    }

    function updateFee(uint256 _fee, uint256 _tokenFee) external onlyOwner {
        require(fee != _fee && tokenFee != _tokenFee, "fee is setted");
        require(getState() == State.Upcoming, "presale cannot be modified");
        fee = _fee;
        tokenFee = _tokenFee;
    }

    function updateRate(uint256 _presaleRate) external onlyOwner {
        require(presaleRate != _presaleRate, "presaleRate is setted");
        require(getState() == State.Upcoming, "presale cannot be modified");
        presaleRate = _presaleRate;
    }

    function updateContribution(uint256[2] memory _contributionSettings)
        external
        onlyOwner
    {
        require(
            _contributionSettings.length == 2,
            "_contributionSettings faild"
        );
        require(getState() == State.Upcoming, "presale cannot be modified");

        minImum = _contributionSettings[0];
        maxImum = _contributionSettings[1];
    }

    function updateCap(uint256[2] memory _capSettings) external onlyOwner {
        require(_capSettings.length == 2, "_capSettings faild");
        require(getState() == State.Upcoming, "presale cannot be modified");
        minCap = _capSettings[0];
        maxCap = _capSettings[1];
    }

    function updateTime(uint256[2] memory _timeSettings) external onlyOwner {
        require(_timeSettings.length == 2, "_timeSettings faild");
        require(getState() == State.Upcoming, "presale cannot be modified");
        startTime = _timeSettings[0];
        endTime = _timeSettings[1];
    }

    function updatePoolDetails(string memory _poolDetails) external onlyOwner {
        require(getState() == State.Upcoming, "presale cannot be modified");
        additionalInfo = _poolDetails;
    }

    function updateCompletedKyc(bool _isCompleted) external onlyOwner {
        require(isCompleted != _isCompleted);
        require(getState() == State.Upcoming, "presale cannot be modified");
        isCompleted = _isCompleted;
    }

    function distributePurchasedTokens(uint256 start, uint256 end)
        external
        onlyOwner
    {
        require(getState() == State.Ended, "presale is not Ended");
        require(start <= end && end <= contributionList.length - 1);
        for (start; start <= end; start++) {
            address _addr = contributionList[start];
            uint256 _amount = contributionAmount[_addr].mul(presaleRate);
            if (!contributionIsClaim[_addr]) {
                require(IERC20(token).balanceOf(address(this)) >= _amount);
                contributionIsClaim[_addr] = true;
                IERC20(token).transfer(_addr, _amount);
            }
        }
    }

    function distributeRefund(uint256 start, uint256 end) external onlyOwner {
        require(getState() == State.Canceled, "presale is not Canceled");
        require(start <= end && end <= contributionList.length - 1);
        for (start; start <= end; start++) {
            address _addr = contributionList[start];
            uint256 _amount = contributionAmount[_addr];
            if (!contributionIsRefund[_addr]) {
                require(address(this).balance >= _amount);
                contributionIsRefund[_addr] = true;
                payable(_addr).transfer(_amount);
            }
        }
    }

    function withdraw() external onlyOwner {
        require(getState() == State.Ended, "presale is not Ended");
        require(address(this).balance >= totalContribution);
        uint256 _amount = totalContribution;
        uint256 _cxAmount = CXAmount;
        _amount = _amount + _cxAmount;
        payable(withdrawMainWallet).transfer(_amount);
        selfdestruct(payable(market));
    }

    function withdrawToken() external onlyOwner {
        require(
            totalClaimed >= totalContribution.mul(presaleRate),
            "someone is not claimed"
        );
        IERC20(token).transfer(
            withdrawTokenWallet,
            IERC20(token).balanceOf(address(this))
        );
    }

    function getWhiteList(uint256 start, uint256 end)
        external
        view
        returns (address[] memory)
    {
        require(start <= end && end <= whitelisted.length - 1);
        address[] memory whitelists = new address[](end + 1);
        uint256 i = 0;
        for (start; start <= end; start++) {
            whitelists[i] = whitelisted[start];
            i++;
        }
        return whitelists;
    }

    function getContributorCount() external view returns (uint256) {
        return contributionList.length;
    }

    function getContributors(uint256 start, uint256 end)
        external
        view
        returns (address[] memory)
    {
        require(start <= end && end <= contributionList.length - 1);
        address[] memory contributors = new address[](end + 1);
        uint256 i = 0;
        for (start; start <= end; start++) {
            contributors[i] = contributionList[start];
            i++;
        }
        return contributors;
    }

    function getState() public view returns (State) {
        State _state;
        if (state == State.Canceled || state == State.Ended) {
            return state;
        }

        if (block.timestamp < startTime) {
            _state = State.Upcoming;
        }
        if (startTime <= block.timestamp && block.timestamp < endTime) {
            _state = State.Inprogress;
        }
        if (block.timestamp >= endTime) {
            if (totalContribution >= minCap) {
                _state = State.Filled;
            } else {
                _state = State.Canceled;
            }
        }
        if (totalContribution == maxCap) {
            _state = State.Filled;
        }

        return _state;
    }

    function getAllInfo()
        external
        view
        returns (
            address[5] memory,
            uint256[7] memory,
            bool,
            string memory,
            State
        )
    {
        return (
            [owner(), main, token, withdrawMainWallet, withdrawTokenWallet],
            [presaleRate, minImum, maxImum, minCap, maxCap, startTime, endTime],
            useWhitelisting,
            additionalInfo,
            getState()
        );
    }

    receive() external payable {}

    fallback() external payable {
        require(msg.data.length == 0);
    }
}

contract LaunchpadFactory is Ownable {
    Launchpad[] public launchpads;
    uint256 public createFee = 0.01 ether;
    event CreateLaunchpad(address owner, address contractAddress);

    function createLaunchpad(
        address _owner,
        address[4] memory _addrs,
        uint256 _rateSetting,
        uint256[2] memory _contributionSettings,
        uint256[2] memory _capSettings,
        uint256[2] memory _timeSettings,
        bool _useWhitelisting,
        string memory _poolDetails
    ) public payable returns (Launchpad contractAddress) {
        require(msg.value >= createFee, "value is not enough for fee");
        contractAddress = new Launchpad(
            _owner,
            _addrs,
            _rateSetting,
            _contributionSettings,
            _capSettings,
            _timeSettings,
            _useWhitelisting,
            _poolDetails
        );
        launchpads.push(contractAddress);
        emit CreateLaunchpad(_owner, address(contractAddress));
    }

    function getLaunchpadCount() external view returns (uint256) {
        return launchpads.length;
    }

    function getLaunchpadList(uint256 start, uint256 end)
        external
        view
        returns (address[] memory list)
    {
        require(start <= end && end <= launchpads.length - 1);
        uint256 i = 0;
        list = new address[](end + 1);
        for (start; start <= end; start++) {
            list[i] = launchpads[start].thisToken();
            i++;
        }
    }

    function setCreateFee(uint256 _fee) external onlyOwner {
        createFee = _fee;
    }

    function withdraw(address _wallet) external onlyOwner {
        payable(_wallet).transfer(address(this).balance);
    }

    function withdrawToken(address _wallet, address _token) external onlyOwner {
        IERC20(_token).transfer(
            _wallet,
            IERC20(_token).balanceOf(address(this))
        );
    }

    receive() external payable {}

    fallback() external payable {
        require(msg.data.length == 0);
    }
}