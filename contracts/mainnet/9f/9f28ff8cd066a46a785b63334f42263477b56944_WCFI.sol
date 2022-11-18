// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./Ownable.sol";
import "./ERC721.sol";
import "./ERC721Enumerable.sol";
import "./AccessControlEnumerable.sol";
import "./ERC721URIStorage.sol";
import "./ERC721Burnable.sol";
import "./SafeMath.sol";
import "./IERC20.sol";
import "./VRFCoordinatorV2Interface.sol";
import "./VRFConsumerBaseV2.sol";


contract WCFI is ERC721URIStorage, ERC721Burnable, VRFConsumerBaseV2, Ownable
{
    using SafeMath for uint256;

    // CHAINLINK parameter
    VRFCoordinatorV2Interface COORDINATOR;
    uint64 subscriptionId;
    bytes32 keyHash;
    uint32 callbackGasLimit;

    // Public variables
    uint256          public tokenCounter;
    FlagInfo[]       public flags;
    IERC20           immutable USDT;
    uint256          public totalPool;
    uint256          public totalBurn;
    bool             public isEndGame;
    uint256          public NFTPrice;
    uint256          public mu = 60000;
    uint256          public sigma = 25000;
    uint256          public burnPrice;
    uint8            public freeNFTFrequency;
    uint8            public poolPercent;
    uint256          public remainFlag;
    bool             public lockUserMint;
    address          public root;
    address          public marketAddress;
    uint256          public operatorReward;

    // Mapping 
    mapping(uint256 => Request) public requestIdSender;
    mapping(address => Account) private accountInfo;

    // Event
    event AddedBlackList(address _by, address indexed _user);
    event RemovedBlackList(address _by, address indexed _user);
    event RandomNFT(address user, uint256 tokenId);
    event Commission(address sender, address referrer, uint256 amount);
    event WithdrawCommission(address user, uint256 amount);
    event BurnNFT(address sender, uint256[3] tokenIds);
    event RequestNFT(uint256 requestId, address sender);
    event FinishRequestNFT (uint256 requestId, address sender, uint256[] listTokenId);

    struct Account {
        bool avalable;
        address parent;
        uint256 refPercent;
        uint256 commission;
        uint256 claimedCommission;
        uint256 numNFT;
    }

    struct Request {
        address sender;
        uint32 numOfNFT;
        uint256 _maxRange;
    }   

    struct FlagInfo {
        string uri;
        uint256 minRate;
        uint256 maxRate;
        bool available;
        uint256[] listTokenId;
        uint256 numNFT;
    }

    constructor(
        address _vrfCoordinator,
        bytes32 _keyHash,
        uint32 _callbackGasLimit,
        uint8 _percent,
        uint64 _subscriptionId,
        address _usdtToken,
        uint256 _NFTprice,
        uint256 _convertPrice
    )  VRFConsumerBaseV2(_vrfCoordinator)  ERC721("Qatar Wolrdcup NFT", "QatarWC") {

        subscriptionId = _subscriptionId;
        keyHash = _keyHash;
        callbackGasLimit = _callbackGasLimit;
        COORDINATOR = VRFCoordinatorV2Interface(_vrfCoordinator);
        poolPercent = _percent;
        USDT = IERC20(_usdtToken);
        root = msg.sender;
        isEndGame =  false;
        lockUserMint = false;
        NFTPrice = _NFTprice;
        burnPrice = _convertPrice;
        freeNFTFrequency = 2;
        accountInfo[msg.sender] = Account(true, address(0), 25, 0, 0, 0);
    }

    function addFlag(string[] memory _uri, uint256[] memory _rate) external  onlyOwner {
        for (uint256 i = 0; i < _uri.length; i++) {
            if (i == 0) {
                flags.push(FlagInfo(_uri[i], 0, _rate[i], true, new uint256[](0), 0));
            } else {
                flags.push(FlagInfo(_uri[i], _rate[i-1], _rate[i], true, new uint256[](0), 0));
            }
        }

        remainFlag = 32;
    }

    modifier whenNotLockMinted() {
        require(!lockUserMint, "Lock mint by user.");
        _;
    }

    function getAccoutInfo() external view returns(Account memory _account) {
        _account = accountInfo[msg.sender];
        return _account;
    }

    function setParameter(
        address _marketAddress,
        uint8 _frequency,
        uint256 _NFTprice,  
        uint256 _convertPrice,
        bool _lockMint
    ) external onlyOwner {
        if (_frequency != freeNFTFrequency) {
            freeNFTFrequency = _frequency;
        }

        if (_NFTprice != NFTPrice) {
            NFTPrice = _NFTprice;
        }

        if (_convertPrice != burnPrice) {
            burnPrice = _convertPrice;
        }
        
        if (_lockMint != lockUserMint) {
            lockUserMint = _lockMint;
        }

        if (_marketAddress != marketAddress) {
            marketAddress = _marketAddress;
        }
    }

    function addRef(address _user, address _parent, uint256 _percent) external onlyOwner {
        require(_user != address(0), "user address is zero");
        require(_parent != address(0), "parent address is zero");
        require(_user != _parent, "user and parent address is same");
        require(!accountInfo[_user].avalable, "user is exist");
        require(accountInfo[_parent].avalable, "parent is not exist");
        
        Account storage _account = accountInfo[_user];
        _account.avalable = true;
        _account.refPercent = _percent;
    }   

    function buyNFT(address _ref) external whenNotLockMinted {
        require(msg.sender != _ref, "sender and ref must be different");
        require(accountInfo[_ref].avalable == true, "referrer is not valid");
        require(!isEndGame, "END_GAME");
        require(!lockUserMint, "LOCK_MINT");
        require(USDT.allowance(msg.sender, address(this)) >= NFTPrice, "ERC20: insufficient allowance");
        require(USDT.balanceOf(msg.sender) >= NFTPrice, "ERC20: transfer amount exceeds balance");

        USDT.transferFrom(msg.sender, address(this), NFTPrice);

        uint256 priceAddPool = NFTPrice.mul(poolPercent).div(100);
        uint256 refAmount = NFTPrice.mul(accountInfo[_ref].refPercent).div(100);

        totalPool += priceAddPool;
        operatorReward += NFTPrice - priceAddPool - refAmount;
        accountInfo[_ref].commission += refAmount;
        
        Account storage _account = accountInfo[msg.sender];
        _account.parent = _ref;
        _account.numNFT += 1;

        _requestRandomNFT(msg.sender, 1, 100000);
        emit Commission(msg.sender, _ref, refAmount);
    }
    
    function convertNFT(uint256[3] memory tokenIds) external {
        require(!isEndGame, "END_GAME");
        require(!lockUserMint, "LOCK_MINT");
        require(USDT.allowance(msg.sender, address(this)) >= burnPrice, "ERC20: insufficient allowance");
        require(USDT.balanceOf(msg.sender) >= burnPrice, "ERC20: transfer amount exceeds balance");

        uint256 _maxRange = 0;

        for (uint i = 0; i < tokenIds.length; ) {
            string memory token_uri = tokenURI(tokenIds[i]);
            for (uint j = 0; j < flags.length; ) {
                if (keccak256(abi.encodePacked(flags[j].uri)) == keccak256(abi.encodePacked(token_uri)) && flags[j].maxRate > _maxRange) {
                    _maxRange = flags[j].maxRate;
                }

                unchecked {
                    ++j;
                }
            }

            burn(tokenIds[i]);

            unchecked {
                ++i;
                totalBurn++;
            }
        }

        if (burnPrice > 0) {
            USDT.transferFrom(msg.sender, address(this), burnPrice);
            operatorReward += burnPrice;
        }
 
        if (_maxRange == 0) {
            _maxRange = 100000;
        }

        accountInfo[msg.sender].numNFT += 1;
        _requestRandomNFT(msg.sender, 1, _maxRange);
        emit BurnNFT(msg.sender, tokenIds);
    }


    function claimCommission() external  {
        Account storage _account = accountInfo[msg.sender];
        require(_account.commission > 0, "commission is zero");

        require(USDT.transfer(msg.sender, _account.commission), "cannot claim commission");

        _account.claimedCommission += _account.commission;
        _account.commission = 0;
        emit WithdrawCommission(msg.sender, _account.commission);
        
    }

    function endGame(uint256 _index) external onlyOwner {
        
        uint256 _totalWinner = flags[_index].listTokenId.length;
        uint256 reward = totalPool.div(_totalWinner);
        uint256 _totalPool = totalPool;

        for (uint i = 0; i < _totalWinner;) {
            address owner = ownerOf(flags[_index].listTokenId[i]);
            if (owner != address(0) && owner != marketAddress) {
                Account storage _account = accountInfo[owner];
                _account.commission +=  reward;
            } else {
                operatorReward += reward;
            }

            _totalPool -= reward;
            unchecked {
                ++i;    
            }
        }

        if (_totalPool > 0) {
            operatorReward += _totalPool;
        }

        isEndGame = true;
    }

    function adminClaim(address _sender, uint256 _amount) external onlyOwner {
        require(_sender != address(0), "address is zero");
        require(_amount > 0, "amount is zero");
        require(_amount <= operatorReward, "amount is greater than operator reward");

        require(USDT.transfer(_sender, _amount), "cannot claim reward");

        operatorReward -= _amount;
    }

    
    function _requestRandomNFT(address _sender, uint32 _num, uint256 _maxRange) internal {
        uint256 requestId = COORDINATOR.requestRandomWords(
            keyHash,
            subscriptionId,
            3,
            callbackGasLimit,
            1
        );

        Request storage _request = requestIdSender[requestId];
        _request.sender = _sender;
        _request.numOfNFT = _num;
        _request._maxRange = _maxRange;

        emit RequestNFT(requestId, _sender);
    }

    function fulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) internal override {
        uint32 numOfNFT = 0;
        
        Request memory originalCaller = requestIdSender[_requestId];

        Account storage _account = accountInfo[originalCaller.sender];
        if (_account.numNFT % freeNFTFrequency == 0) {
            numOfNFT = originalCaller.numOfNFT + 1;
        } else {
            numOfNFT = originalCaller.numOfNFT;
        }

        uint256[] memory flagIPFSIndex = getRandomFlag(
            _randomWords[0], 
            numOfNFT, 
            originalCaller._maxRange
        );

        uint256[] memory listNewTokenId = new uint256[](numOfNFT);
        for (uint i = 0; i < numOfNFT; ) {
            
            uint256 newTokenId = tokenCounter;
            _safeMint(originalCaller.sender, newTokenId);
            _setTokenURI(newTokenId, flags[flagIPFSIndex[i]].uri);

            // increase number of nft of flag
            flags[flagIPFSIndex[i]].listTokenId.push(newTokenId);
            flags[flagIPFSIndex[i]].numNFT += 1;

            listNewTokenId[i] = newTokenId;
       
            unchecked {
                tokenCounter+=1;
                ++i;
            }
        }

        emit FinishRequestNFT(_requestId, originalCaller.sender, listNewTokenId);
    }

    
    function disableFlags(uint[] memory _indexs) external onlyOwner  {
        
        remainFlag -= _indexs.length;
        uint256 _totalNFTRemove = 0;
        
        // diable flag and increase total nft will be removed
        for (uint8 i = 0; i < _indexs.length; ) {
            flags[_indexs[i]].available = false;
            _totalNFTRemove += flags[_indexs[i]].listTokenId.length;

            unchecked {
                ++i;
            }
        }

        uint256[] memory newRate = new uint256[](remainFlag);
        uint[] memory remainFlagIndex = new uint[](remainFlag);
        uint256 sumRate;
        uint8 newRateIndex = 0;

        // recalculate new rate
        for (uint8 i = 0; i < flags.length; ){
            if (flags[i].available) {
                uint256 _rate = flags[i].listTokenId.length * 10**5 + (_totalNFTRemove * 10 ** 5) / remainFlag;
                
                sumRate += _rate;
                newRate[newRateIndex] = _rate;
                remainFlagIndex[newRateIndex] = i;
                
                unchecked {
                    ++newRateIndex;
                }
            }
            
            unchecked {
                ++i;
            }
        }
        
        // update new rate
        for (uint i = 0; i < remainFlagIndex.length; ){
            if (i == 0) {
                flags[remainFlagIndex[i]].minRate = 0;
                flags[remainFlagIndex[i]].maxRate = (newRate[i] * 10**5) / sumRate;
            } else {
                flags[remainFlagIndex[i]].minRate = flags[remainFlagIndex[i-1]].maxRate;
                flags[remainFlagIndex[i]].maxRate = flags[remainFlagIndex[i]].minRate +  ((newRate[i] * 10**5) / sumRate);
            }
            
            unchecked {
                ++i;
            }
        }
    }

    function getRandomFlag(uint256 _randomNum,  uint256 _n, uint256 _maxRange) internal view returns(uint256[] memory) {
        int256[] memory finalRandom = _normalRNG(_randomNum, _n);
        uint256[] memory result = new uint256[](_n);

        for (uint j = 0; j < _n; ) {
            if (finalRandom[j] < 0) {
                finalRandom[j] = int256(mu);
            }

            if (finalRandom[j] > int(_maxRange)) {
                finalRandom[j] = int(_maxRange);
            }

            for (uint i = flags.length - 1; i >= 0 ; ) {
                if (flags[i].available) {
                    
                    if (finalRandom[j] > int(flags[i].minRate) && finalRandom[j] <= int(flags[i].maxRate)) {
                        result[j] = i;
                        break;
                    }
                }

                unchecked {
                    --i;
                }
            }

            unchecked {
                ++j;
            }
        }

        return result;
    }

    function _normalRNG(uint256 _randomNum,  uint256 _n) internal view returns (int256[] memory) {
        uint256[] memory random_array = _expand(_randomNum, _n);
        int256[] memory final_array = new int256[](_n);

        for (uint256 i = 0; i < _n; i++) {

            
            uint256 result = _countOnes(random_array[i]); 
            final_array[i] = int256(int256(result) * int256(sigma)/8) - 128*int256(sigma)/8 + int256(mu);
        }

        return final_array;
    }

    function _countOnes(uint256 n) internal pure returns (uint256 count) {
        // Count the number of ones in the binary representation
        // internal function in assembly to count number of 1's
        // https://www.geeksforgeeks.org/count-set-bits-in-an-integer/
        assembly {
            for { } gt(n, 0) { } {
                n := and(n, sub(n, 1))
                count := add(count, 1)
            }
        }
    }

    function _expand(uint256 _randomValue, uint256 _n) internal pure returns (uint256[] memory expandedValues) {
        //generate n pseudorandom numbers from a single one
        //https://docs.chain.link/docs/chainlink-vrf-best-practices/#getting-multiple-random-numbers
        expandedValues = new uint256[](_n);
        for (uint256 i = 0; i < _n; i++) {
            expandedValues[i] = uint256(keccak256(abi.encode(_randomValue, i)));
        }
        return expandedValues;
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage ) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage ) returns (string memory)  {
        return super.tokenURI(tokenId);
    }

    function _beforeTokenTransfer(
        address _from,
        address _to,
        uint256 _tokenId
    ) internal override(ERC721)  {
        if(_to == marketAddress) {
            approve(marketAddress, _tokenId);
        }
        super._beforeTokenTransfer(_from, _to, _tokenId);
    }
}