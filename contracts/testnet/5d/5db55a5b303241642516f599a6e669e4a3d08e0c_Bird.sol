// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./Ownable.sol";
import "./ERC721Enumerable.sol";
import "./ReentrancyGuard.sol";
import "./BugCoin.sol";
import "./Whitelist.sol";
import "./ERC721.sol";
import "./IERC721.sol";


contract Bird is ERC721Enumerable, ReentrancyGuard, Ownable, Whitelist  {

    string public baseTokenURI = "ipfs://1/";

    uint256 public MAX_BIRD = 10000;
    uint256 public namingBirdPrice = 0.1 ether;
    uint256 public rewardPrice = 0.05 ether;
    uint256 public mintPrice = 0.1 ether;
    uint256 public whiteListMintPrice = 0 ether;
    uint256 public mintTokenPrice = 100 ether;


    address public teamAddress = 0x3d9865f8e5b702220A43b81F1D05580e6F7A8327;
    address public nameAddress = 0x3d9865f8e5b702220A43b81F1D05580e6F7A8327;
    uint256 public teamFee = 5;
    uint256 public maxMintAmount = 1000;
    uint256 public maxWLMintAmount = 1;
    uint256 public maxTokenMintAmount = 1000;


    bool public mintIsActive = false;
    bool public tokenMintIsActive = true;
    bool public whiteListMintIsActive = false;


    mapping(uint256 => string) public nameBird;
    mapping(address => uint256) public balanceBird;

    BugCoin public bugCoin;

    event NameChanged(string name);

    constructor() ERC721("Bird", "Bird") {
    }

    function _baseURI() internal view override returns (string memory) {
        return baseTokenURI;
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        baseTokenURI = baseURI;
    }

    function setBugCoin(address _address) external onlyOwner {
        bugCoin = BugCoin(_address);
    }


    function setTeamFee(uint256 _teamFee) external onlyOwner {
        teamFee = _teamFee;
    }

    function setMaxMintAmount(uint256 _amount) external onlyOwner {
        maxMintAmount = _amount;
    }

    function setMaxWLMintAmount(uint256 _amount) external onlyOwner {
        maxWLMintAmount = _amount;
    }

    function setMaxTokenMintAmount(uint256 _amount) external onlyOwner {
        maxTokenMintAmount = _amount;
    }


    function setBalanceBird(address wallet, uint256 _newBalance) external onlyOwner {
        balanceBird[wallet] = _newBalance;
    }

    function setNamingPrice(uint256 _namingPrice) external onlyOwner {
        namingBirdPrice = _namingPrice;
    }

    function setRewardPrice(uint256 _rewardPrice) external onlyOwner {
        rewardPrice = _rewardPrice;
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0);

        payable(msg.sender).transfer(balance);
    }

    function setTeamAddress(address _teamAddress) external onlyOwner {
        teamAddress = _teamAddress;
    }

    function setNameAddress(address _nameAddress) external onlyOwner {
        nameAddress = _nameAddress;
    }
  /**
    * @dev Allow contract owner to withdraw ERC-20 balance from contract
    * while still splitting royalty payments to all other team members.
    * in the event ERC-20 tokens are paid to the contract.
    * @param _tokenContract contract of ERC-20 token to withdraw
    * @param _amount balance to withdraw according to balanceOf of ERC-20 token
    */
  function withdrawAllERC20(address _tokenContract, uint256 _amount) public onlyOwner {
    require(_amount > 0);
    IERC20 tokenContract = IERC20(_tokenContract);
    require(tokenContract.balanceOf(address(this)) >= _amount, 'Contract does not own enough tokens');
    tokenContract.transfer(msg.sender, _amount );
  }

    function setMintActive() public onlyOwner {
        mintIsActive = !mintIsActive;
    }

    function setTokenMintIsActive() public onlyOwner {
        tokenMintIsActive = !tokenMintIsActive;
    }

    function setWhiteListMintIsActive() public onlyOwner {
        whiteListMintIsActive = !whiteListMintIsActive;
    }


    function mintAdmin(uint256[] calldata tokenIds, address _to) public payable onlyOwner {
        require(totalSupply() + tokenIds.length <= MAX_BIRD, "Minting would exceed max supply of NFTs");

        for(uint256 i = 0; i < tokenIds.length; i++) {
            require(tokenIds[i] < MAX_BIRD, "Invalid token ID");
            require(!_exists(tokenIds[i]), "Tokens has already been minted");

            if (totalSupply() < MAX_BIRD) {
                _safeMint(_to, tokenIds[i]);
                balanceBird[_to] += 1;
            }
        }
        //update reward on mint
        bugCoin.updateRewardOnMint(_to, tokenIds.length);
    }

    function mint(uint256 _amount) public payable nonReentrant {
        require(mintIsActive, "Mint is closed");
        require(totalSupply() + _amount <= MAX_BIRD, "Minting would exceed max supply of NFTs");
        require(balanceOf(msg.sender) + _amount<=maxMintAmount, "Wallet address is over the maximum allowed mints");
        require(msg.value == mintPrice*_amount, "Value needs to be exactly the reward fee!");

        for(uint256 i = 0; i < _amount; i++) {
            if (totalSupply() < MAX_BIRD) {
                _safeMint(msg.sender,totalSupply()+1);
                balanceBird[msg.sender] += 1;
            }
        }
        //update reward on mint
        bugCoin.updateRewardOnMint(msg.sender, _amount);
    }

    function tokenMint(uint256 _amount) public payable nonReentrant {
        require(tokenMintIsActive, "Token mint is closed");
        require(totalSupply() + _amount <= MAX_BIRD, "Minting would exceed max supply of NFTs");
        require(balanceOf(msg.sender) + _amount<=maxTokenMintAmount, "Wallet address is over the maximum allowed mints");
		require(bugCoin.balanceOf(msg.sender) >=mintTokenPrice * _amount, "Balance insufficient");


        uint256 teamAmount = mintTokenPrice * _amount* teamFee / 100;
        uint256 burnAmount = mintTokenPrice * _amount* (100-teamFee) / 100;

        bugCoin.burnFrom(msg.sender, burnAmount); 
        bugCoin.transferFeeFrom(msg.sender,teamAddress,teamAmount); 
		

        for(uint256 i = 0; i < _amount; i++) {
            if (totalSupply() < MAX_BIRD) {
                _safeMint(msg.sender,totalSupply()+1);
                balanceBird[msg.sender] += 1;
            }
        }
        //update reward on mint
        bugCoin.updateRewardOnMint(msg.sender, _amount);
    }



    function mintToWhiteList(address _to,uint256 _amount, bytes32[] calldata _merkleProof) public payable nonReentrant {
        require(whiteListMintIsActive, "Whitelist minting is closed");
        require(isWhitelisted(_to, _merkleProof), "Address is not in Allowlist!");
        require(totalSupply() + _amount <= MAX_BIRD, "Minting would exceed max supply of NFTs");
        require(balanceOf(msg.sender) + _amount<=maxWLMintAmount, "Wallet address is over the maximum allowed mints");
        require(msg.value == whiteListMintPrice*_amount, "Value needs to be exactly the reward fee!");
        
        for(uint256 i = 0; i < _amount; i++) {
            if (totalSupply() < MAX_BIRD) {
                _safeMint(msg.sender,totalSupply()+1);
                balanceBird[msg.sender] += 1;
            }
        }
        //update reward on mint
        bugCoin.updateRewardOnMint(msg.sender, _amount);    
        }

    function transferFrom(address from, address to, uint256 tokenId) public override nonReentrant {
        bugCoin.updateReward(from, to, tokenId);
        balanceBird[from] -= 1;
        balanceBird[to] += 1;
        ERC721.transferFrom(from, to, tokenId);
    }



    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public override nonReentrant {
        bugCoin.updateReward(from, to, tokenId);
        balanceBird[from] -= 1;
        balanceBird[to] += 1;

        ERC721.safeTransferFrom(from, to, tokenId, _data);
    }

    function getReward() external payable {
        require(msg.value == rewardPrice, "Value needs to be exactly the reward fee!");
        bugCoin.updateReward(msg.sender, address(0), 0);
        bugCoin.getReward(msg.sender);
    }

    function changeName(uint256 _tokenId, string memory _newName) public {
        require(ownerOf(_tokenId) == msg.sender);
        require(validateName(_newName) == true, "Invalid name");
        
        //can not set the same name
        for (uint256 i; i < totalSupply(); i++) {
            if (bytes(nameBird[i]).length != bytes(_newName).length) {
                continue;
        } else {
            require(keccak256(abi.encode(nameBird[i])) != keccak256(abi.encode(_newName)), "name is used");
        }
        }

        bugCoin.transferFeeFrom(msg.sender,nameAddress,namingBirdPrice); 
        nameBird[_tokenId] = _newName;
        emit NameChanged(_newName);
    }

    function validateName(string memory str) internal pure returns (bool) {
        bytes memory b = bytes(str);

        if(b.length < 1) return false;
        if(b.length > 15) return false;
        if(b[0] == 0x20) return false; // Leading space
        if(b[b.length - 1] == 0x20) return false; // Trailing space

        bytes1 lastChar = b[0];


        for (uint256 i; i < b.length; i++) {
            bytes1 char = b[i];

            if (char == 0x20 && lastChar == 0x20) return false; // Cannot contain continous spaces

            if (
                !(char >= 0x30 && char <= 0x39) && //9-0
                !(char >= 0x41 && char <= 0x5A)  //A-Z
            ) {
                return false;
            }

            lastChar = char;
        }

        return true;
    }
}