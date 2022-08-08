/**
 *Submitted for verification at BscScan.com on 2022-08-08
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IERC721 {
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 indexed _tokenId
    );
    event Approval(
        address indexed _owner,
        address indexed _approved,
        uint256 indexed _tokenId
    );
    event ApprovalForAll(
        address indexed _owner,
        address indexed _operator,
        bool _approved
    );

    function balanceOf(address _owner) external view returns (uint256);

    function ownerOf(uint256 _tokenId) external view returns (address);

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes calldata data
    ) external payable;

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable;

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable;

    function approve(address _approved, uint256 _tokenId) external payable;

    function setApprovalForAll(address _operator, bool _approved) external;

    function getApproved(uint256 _tokenId) external view returns (address);

    function isApprovedForAll(address _owner, address _operator)
        external
        view
        returns (bool);

    function totalSupply() external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index)
        external
        view
        returns (uint256);

    function tokenByIndex(uint256 index) external view returns (uint256);

    function MAX_TOTAL_SUPPLY() external view returns (uint256);

    function isMint(uint256 input) external view returns (bool);

    function walletOfUser(address owner)
        external
        view
        returns (uint256[] memory);
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

    function decimals() external view returns (uint8);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract Testing123 {
    mapping(uint256 => uint256) public NFTHolderReward;
    mapping(address => bool) public owner;
    mapping(uint256 => mapping(address => uint256))
        public tokenWithAddressClaimedReward;
    mapping(uint256 => uint256) public amountOfRewardByToken;
    mapping(address => uint256) public amountOfRewardByAddress;

    IERC721 public nftContract;
    IERC20 public rewardTokenContract;

    modifier onlyOwner() {
        require(owner[msg.sender] == true);
        _;
    }

    constructor(
        address _owner,
        IERC721 _nftAddress,
        IERC20 _rewardTokenAddress
    ) public {
        owner[_owner] = true;
        owner[msg.sender] = true;
        nftContract = _nftAddress;
        rewardTokenContract = _rewardTokenAddress;
    }

    function depositReward(uint256 _totalRewardAmoount) external onlyOwner {
        uint256 maxTotalSupply = _maxTotalSupply();
        uint256 totalSupply = _fetchTotalSupply();
        uint256 perAmount = _totalRewardAmoount / totalSupply;
        for (uint256 i = 1; i <= maxTotalSupply; i++) {
            if (_isMint(i)) {
                NFTHolderReward[i] = NFTHolderReward[i] + perAmount;
            }
        }
    }

    function claimRewardAll() external {
        uint256 maxTotalSupply = _maxTotalSupply();
        uint256 totalReward = 0;
        uint256[] memory walletOfUser = _fetchWalletOfUser(msg.sender);
        bool didHaveNft = walletOfUser.length > 0;
        require(didHaveNft, "Need to have nft for claim reward");
        for (uint256 i = 0; i < walletOfUser.length; i++) {
            totalReward = totalReward + NFTHolderReward[walletOfUser[i]];
        }
        bool hasReward = totalReward > 0;
        require(
            hasReward,
            "You dont have any reward tokens to claim on this NFT"
        );

        bool sent = rewardTokenContract.transfer(msg.sender, totalReward);
        require(sent, "Token transfer failed");
        amountOfRewardByAddress[msg.sender] =
            amountOfRewardByAddress[msg.sender] +
            totalReward;
        for (uint256 i = 0; i < walletOfUser.length; i++) {
            uint256 tokenId = walletOfUser[i];
            amountOfRewardByToken[tokenId] += NFTHolderReward[tokenId];
            tokenWithAddressClaimedReward[tokenId][
                msg.sender
            ] += NFTHolderReward[tokenId];
            NFTHolderReward[tokenId] = 0;
        }
    }

    function claimRewards(uint256 _tokenId) external {
        uint256 reward = NFTHolderReward[_tokenId];
        bool hasReward = reward > 0;
        require(
            hasReward,
            "You dont have any reward tokens to claim on this NFT"
        );
            bool tokenOwner = _isMint(_tokenId) &&
                _fetchOwnerOf(_tokenId) == msg.sender;
            require(tokenOwner, "Only NFT owner can claim reward");
            bool sent = rewardTokenContract.transfer(msg.sender, reward);
            require(sent, "Token transfer failed");
            amountOfRewardByAddress[msg.sender] =
                amountOfRewardByAddress[msg.sender] +
                reward;
            amountOfRewardByToken[_tokenId] += NFTHolderReward[_tokenId];
            tokenWithAddressClaimedReward[_tokenId][
                msg.sender
            ] += NFTHolderReward[_tokenId];
            NFTHolderReward[_tokenId] = 0;
        
    }

    function _fetchTotalSupply() private view returns (uint256) {
        return nftContract.totalSupply();
    }

    function _ownerOf(uint256 _tokenId) private view returns (address) {
        return nftContract.ownerOf(_tokenId);
    }

    function _maxTotalSupply() private view returns (uint256) {
        return nftContract.MAX_TOTAL_SUPPLY();
    }

    function _isMint(uint256 _tokenId) private view returns (bool) {
        return nftContract.isMint(_tokenId);
    }

    function _fetchOwnerOf(uint256 _tokenId) public view returns (address) {
        return nftContract.ownerOf(_tokenId);
    }

    function setNftContractAddress(IERC721 _nftAddress) external onlyOwner {
        nftContract = _nftAddress;
    }

    function setRewardContractAddress(IERC20 _rewardTokenContract)
        external
        onlyOwner
    {
        rewardTokenContract = _rewardTokenContract;
    }

    function _fetchWalletOfUser(address _owner)
        private
        view
        returns (uint256[] memory)
    {
        return nftContract.walletOfUser(_owner);
    }

    function setOwner(address _owner, bool _flag) external onlyOwner {
        owner[_owner] = _flag;
    }

    function _safeTransfer(
        IERC20 _token,
        address recipient,
        uint256 amount
    ) private onlyOwner {
        bool sent = _token.transfer(recipient, amount);
        require(sent, "Token transfer failed.");
    }

    function getStuckBnb(uint256 amount, address receiveAddress)
        external
        onlyOwner
    {
        payable(receiveAddress).transfer(amount);
    }

    function getStuckToken(
        IERC20 _token,
        address receiveAddress,
        uint256 amount
    ) external onlyOwner {
        _safeTransfer(_token, receiveAddress, amount);
    }
}