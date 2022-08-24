/**
 *Submitted for verification at BscScan.com on 2022-08-24
*/

// SPDX-License-Identifier: MIT
pragma solidity =0.8.7;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "e5");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "e6");
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "e7");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "e8");
        uint256 c = a / b;
        return c;
    }
}


library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "e0");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "e1");
        }
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "k002");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "k003");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }
    modifier nonReentrant() {
        require(_status != _ENTERED, "k004");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "k005");

        (bool success,) = recipient.call{value : amount}("");
        require(success, "k006");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "k007");
        require(isContract(target), "k008");

        (bool success, bytes memory returndata) = target.call{value : value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "k009");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "k010");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
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

interface ERC721Enumerable {
    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    function tokenIdNow() external view returns (uint256);
}

interface nftStakingPool {

    function stakingNftOlderOwnerList(ERC721Enumerable, uint256) external view returns (address);

    function getUserStakingTokenForPoolIdListSet(ERC721Enumerable, address _user) external view returns (uint256[] memory, uint256);

}

contract nftShareForUGG is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;
    ERC721Enumerable public nftToken;
    address public erc20Token;
    uint256 public distributionAmount;
    nftStakingPool public nftStakingPoolAddress;
    bool public useCheckStakingStatus = false;
    uint256 public minDistributionAmount = 2000 * (10 ** 18);
    uint256 public claimedAmount;
    uint256 public indexes = 0;
    mapping(uint256 => mapping(uint256 => bool)) public tokenIdClaimStatusList;
    mapping(uint256 => uint256) public tokenIdLastIndexList;
    mapping(uint256 => distributionItem) public distributionList;
    mapping(address => bool) public callerList;
    mapping(address => uint256) public userClaimedAmountList;

    struct distributionItem {
        uint256 index;
        uint256 maxTokenId;
        uint256 pershare;
        uint256 totalShare;
    }

    constructor () {
        callerList[msg.sender] = true;
    }

    modifier onlyCaller() {
        require(callerList[msg.sender], "only caller");
        _;
    }

    event claimEvent(address _account, uint256 _tokenID, uint256 _index, uint256 _claimedAmount);
    event doShareEvent(address _account, uint256 _index, uint256 _maxTokenId, uint256 _perShare, uint256 _totalShare);


    function setNftStakingPoolAddress(bool _useCheckStakingStatus, nftStakingPool _nftStakingPoolAddress) external onlyOwner {
        useCheckStakingStatus = _useCheckStakingStatus;
        nftStakingPoolAddress = _nftStakingPoolAddress;
    }

    function setCallerList(address[] calldata _accountList, bool _status) external onlyOwner {
        for (uint256 i = 0; i < _accountList.length; i++) {
            callerList[_accountList[i]] = _status;
        }
    }

    function setNftToken(ERC721Enumerable _nftToken) external onlyOwner {
        nftToken = _nftToken;
    }

    function setErc20Token(address _erc20Token) external onlyOwner {
        erc20Token = _erc20Token;
    }

    function setMinDistributionAmount(uint256 _minDistributionAmount) external onlyOwner {
        minDistributionAmount = _minDistributionAmount;
    }

    function doShare() external nonReentrant onlyCaller {
        uint256 balance = erc20Token == address(0) ? address(this).balance : IERC20(erc20Token).balanceOf(address(this));
        if (balance < minDistributionAmount.add(distributionAmount.sub(claimedAmount))) {
            return;
        }
        uint256 toShareAmount = balance.sub(distributionAmount.sub(claimedAmount));
        uint256 maxTokenId = nftToken.tokenIdNow();
        uint256 perShare = toShareAmount.div(maxTokenId);
        uint256 totalShare = perShare.mul(maxTokenId);
        emit doShareEvent(msg.sender, indexes, maxTokenId, perShare, totalShare);
        distributionList[indexes] = distributionItem(indexes, maxTokenId, perShare, totalShare);
        indexes = indexes.add(1);
        distributionAmount = distributionAmount.add(totalShare);

    }

    function claim(uint256 _tokenId, address _account) internal {
        uint256 lastIndex = tokenIdLastIndexList[_tokenId];
        uint256 totalClaimAmount = 0;
        uint256 balance = erc20Token == address(0) ? address(this).balance : IERC20(erc20Token).balanceOf(address(this));
        uint256 j = 0;
        for (uint256 i = lastIndex; i < lastIndex.add(100); i++) {
            bool hasclaimed = tokenIdClaimStatusList[_tokenId][i];
            distributionItem memory x = distributionList[i];
            if (balance < totalClaimAmount.add(x.pershare) || i >= indexes) {
                break;
            }
            j = j.add(1);
            if (_tokenId <= x.maxTokenId && !hasclaimed) {
                emit claimEvent(_account, _tokenId, i, x.pershare);
                tokenIdClaimStatusList[_tokenId][i] = true;
                totalClaimAmount = totalClaimAmount.add(x.pershare);
            }
        }
        claimedAmount = claimedAmount.add(totalClaimAmount);
        if (totalClaimAmount == 0) {
            return;
        }
        userClaimedAmountList[_account] = userClaimedAmountList[_account].add(totalClaimAmount);
        if (erc20Token == address(0)) {
            payable(_account).transfer(totalClaimAmount);
        } else {
            IERC20(erc20Token).safeTransfer(_account, totalClaimAmount);
        }
        if (j > 0) {
            tokenIdLastIndexList[_tokenId] = tokenIdLastIndexList[_tokenId].add(j);
        }
    }

    function claimByOwner(uint256 _tokenId) external nonReentrant {
        address _account = msg.sender;
        if (useCheckStakingStatus && address(nftStakingPoolAddress) != address(0)) {
            require(nftStakingPoolAddress.stakingNftOlderOwnerList(nftToken, _tokenId) == _account, "not staked");
            claim(_tokenId, _account);
        } else if (!useCheckStakingStatus && address(nftStakingPoolAddress) != address(0)) {
            require(nftToken.ownerOf(_tokenId) == _account || nftStakingPoolAddress.stakingNftOlderOwnerList(nftToken, _tokenId) == _account, "only owner can claim");
            claim(_tokenId, _account);
        }
    }

    function claimForAccount(uint256[] memory idList, address _account) private {
        for (uint256 i = 0; i < idList.length; i++) {
            uint256 _tokenId = idList[i];
            claim(_tokenId, _account);
        }
    }

    function massClaimByOwner() external nonReentrant {
        address _account = msg.sender;
        if (useCheckStakingStatus && address(nftStakingPoolAddress) != address(0)) {
            (uint256[] memory idList,) = nftStakingPoolAddress.getUserStakingTokenForPoolIdListSet(nftToken, _account);
            claimForAccount(idList, _account);
        } else if (!useCheckStakingStatus && address(nftStakingPoolAddress) != address(0)) {
            (uint256[] memory idList,) = nftStakingPoolAddress.getUserStakingTokenForPoolIdListSet(nftToken, _account);
            claimForAccount(idList, _account);
            uint256 balance = nftToken.balanceOf(_account);
            uint256[] memory idList2 = new uint256[](balance);
            for (uint256 i = 0; i < balance; i++) {
                idList2[i] = nftToken.tokenOfOwnerByIndex(_account, i);
            }
            claimForAccount(idList2, _account);
        } else {
            return;
        }
    }

    // function claimByCaller(uint256 _tokenId, address _account) external nonReentrant {
    //     if (useCheckStakingStatus && address(nftStakingPoolAddress) != address(0)) {
    //         require(nftStakingPoolAddress.stakingNftOlderOwnerList(nftToken, _tokenId) == _account, "not staked");
    //         claim(_tokenId, _account);
    //     } else if (!useCheckStakingStatus && address(nftStakingPoolAddress) != address(0)) {
    //         require(nftToken.ownerOf(_tokenId) == _account || nftStakingPoolAddress.stakingNftOlderOwnerList(nftToken, _tokenId) == _account, "only owner can claim");
    //         claim(_tokenId, _account);
    //     }
    // }

    // function massClaimByCaller(address _account) external nonReentrant {
    //     if (useCheckStakingStatus && address(nftStakingPoolAddress) != address(0)) {
    //         (uint256[] memory idList,) = nftStakingPoolAddress.getUserStakingTokenForPoolIdListSet(nftToken, _account);
    //         claimForAccount(idList, _account);
    //     } else if (!useCheckStakingStatus && address(nftStakingPoolAddress) != address(0)) {
    //         (uint256[] memory idList,) = nftStakingPoolAddress.getUserStakingTokenForPoolIdListSet(nftToken, _account);
    //         claimForAccount(idList, _account);
    //         uint256 balance = nftToken.balanceOf(_account);
    //         uint256[] memory idList2 = new uint256[](balance);
    //         for (uint256 i = 0; i < balance; i++) {
    //             idList2[i] = nftToken.tokenOfOwnerByIndex(_account, i);
    //         }
    //         claimForAccount(idList2, _account);
    //     } else {
    //         return;
    //     }
    // }

    function takeToken(uint256 _amount, address _token, address _account) internal {
        uint256 takeAmount;
        if (_amount == 0) {
            takeAmount = _token == address(0) ? address(this).balance : IERC20(_token).balanceOf(address(this));
        } else {
            takeAmount = _amount;
        }
        require(takeAmount > 0, "takeAmount should above zero");
        if (_token == address(0)) {
            payable(_account).transfer(takeAmount);
        } else {
            IERC20(_token).safeTransfer(_account, takeAmount);
        }
    }

    function takeErc20Token(uint256 _amount) external onlyOwner {
        takeToken(_amount, erc20Token, msg.sender);
    }

    function takeAnyToken(uint256 _amount, address _token) external onlyOwner {
        takeToken(_amount, _token, msg.sender);
    }

    struct returnItem {
        distributionItem[] distributionList;
        bool useCheckStakingStatus;
        uint256[] StakingIdList;
        uint256[] IdList;
        address erc20Token;
        ERC721Enumerable nftToken;
        uint256 userClaimedAmount;
        uint256 distributionAmount;
        uint256 claimedAmount;
        uint256 poolBalance;
        uint256[] StakingIdListLastIndexList;
        uint256[] IdListLastIndexList;

    }

    function getNewIdList(uint256[] memory _idList) public view returns (uint256[] memory tokenIdLastIndexList_) {
        tokenIdLastIndexList_ = new uint256[](_idList.length);
        for (uint256 i=0;i<_idList.length;i++) {
           tokenIdLastIndexList_[i] = tokenIdLastIndexList[_idList[i]];
        }
    }

    function getDistributionListByIndexList(address _user,uint256[] memory _indexList) public view returns (returnItem memory userInfo) {
        {
        distributionItem[] memory distributionList_ = new distributionItem[](_indexList.length);
        for (uint256 i=0;i<_indexList.length;i++) {
            distributionList_[i] = distributionList[_indexList[i]];
        }
        userInfo.distributionList = distributionList_;
        }
        userInfo.useCheckStakingStatus = useCheckStakingStatus;
        {
        (uint256[] memory StakingIdList_,) = nftStakingPoolAddress.getUserStakingTokenForPoolIdListSet(nftToken, _user);
        userInfo.StakingIdList = StakingIdList_;
        uint256 balance = nftToken.balanceOf(_user);
        uint256[] memory IdList_ = new uint256[](balance);
        for (uint256 i = 0; i < balance; i++) {
            IdList_[i] = nftToken.tokenOfOwnerByIndex(_user, i);
        }
        userInfo.IdList = IdList_;
        userInfo.StakingIdListLastIndexList = getNewIdList(StakingIdList_);
        userInfo.IdListLastIndexList = getNewIdList(IdList_);
        }
        userInfo.erc20Token = erc20Token;
        userInfo.nftToken = nftToken;
        userInfo.userClaimedAmount = userClaimedAmountList[_user];
        userInfo.distributionAmount = distributionAmount;
        userInfo.claimedAmount = claimedAmount;
        userInfo.poolBalance = erc20Token == address(0) ? address(this).balance : IERC20(erc20Token).balanceOf(address(this));
    }

    function getDistributionList(address _user) public view returns (returnItem memory userInfo) {
       uint256[] memory _indexList = new uint256[](indexes);
       for (uint256 i=0;i<indexes;i++) {
           _indexList[i] = i;
       }
       userInfo = getDistributionListByIndexList(_user,_indexList);
    }

    receive() payable external {}
}