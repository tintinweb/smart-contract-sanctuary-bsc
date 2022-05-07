pragma solidity ^0.8.0;
// SPDX-License-Identifier: MIT
//Dev by FGD team
import "./Ownable.sol";

interface INFT {
    function balanceOf(address owner) external view returns (uint256);

    function ownerOf(uint256 tokenId) external view returns (address);

    function getTokenType(uint256 tokenId) external view returns (uint8);
}

contract ClaimReward is Ownable {
    function safeTransfer(address token, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    mapping(uint256 => uint256) amountMap;

    struct Info {
        uint firstTime;
        uint lastTime;
        uint count;
        uint amount;
    }

    mapping(uint256 => Info)public infos;
    INFT nftContract;
    address public tokenAddress;
    uint256 public startTime;
    uint256 public endTime;
    uint256 oneDay;
    uint256 public oneMonth;

    event Claim(address indexed from, uint256 indexed nftId, uint256 amount);
    constructor(address nft, address _token, uint256 startTime_, uint256 endTime_, uint256 oneDay_) {
        nftContract = INFT(nft);
        startTime = startTime_;
        endTime = endTime_;
        oneDay = oneDay_;
        oneMonth = oneDay * 30;
        tokenAddress = _token;
    }

    function setStartTime(uint256 _start) external onlyOwner {
        startTime = _start;
    }

    function _setTokenAmount(uint8 _type, uint256 _amount) internal checkType(_type) {
        amountMap[_type] = _amount;
    }

    function setTokenAmount(uint8 _type, uint256 _amount) external onlyOwner {
        _setTokenAmount(_type, _amount);
    }

    function setTokenAmountArr(uint8[] memory ts, uint256[] memory amounts) external onlyOwner {
        for (uint i = 0; i < ts.length; i++) {
            _setTokenAmount(ts[i], amounts[i]);
        }
    }

    modifier checkType(uint8 _type) {
        require(_type >= 1 && _type <= 4, "invalid type");
        _;
    }
    modifier checkTime() {
        require(block.timestamp >= startTime, "time:not start");
        _;
    }

    function claim(uint256[] memory ids) external checkTime {
        uint total;
        for (uint256 i = 0; i < ids.length; i++) {
            total += _claimId(ids[i]);
        }
        if (total > 0) {
            safeTransfer(tokenAddress, msg.sender, total);
        }

    }

    function getNFTAmount(uint256 nftId) public view returns (uint256){
        uint _type = nftContract.getTokenType(nftId);
        return amountMap[_type];
    }

    function _claimId(uint256 nftId) internal returns (uint256){
        require(nftContract.ownerOf(nftId) == msg.sender, "ownerOf");
        uint tokenAmount = getNFTAmount(nftId);
        uint curAmount;
        Info storage info = infos[nftId];
        require(info.count < 7, "claimAll");
        if (info.firstTime == 0) {
            curAmount = tokenAmount * 40 / 100;
            info.firstTime = block.timestamp;
            info.lastTime = block.timestamp;
            info.count = 1;
            info.amount = curAmount;
            emit Claim(msg.sender, nftId, curAmount);
        } else {
            uint perAmount = tokenAmount / 10;
            (uint newAmount,uint count, uint newTime) = getAmount(perAmount, info.lastTime);
            if (newAmount > 0) {
                curAmount = newAmount;
                info.lastTime = newTime;
                info.count += count;
                info.amount += newAmount;
                emit Claim(msg.sender, nftId, curAmount);
            }

        }
        return curAmount;
    }


    function getAmount(uint256 tokenAmount, uint last) public view returns (uint256, uint256, uint256){

        if (block.timestamp - last < oneMonth) {
            return (0, 0, last);
        }
        uint day = (block.timestamp - last) / oneMonth;
        uint amount = tokenAmount * day;
        uint newTime = day * oneMonth + last;
        return (amount, day, newTime);
    }
}