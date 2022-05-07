// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "./ERC721Enumerable.sol";

contract WonderFinanceNFT is ERC721Enumerable {
    uint public tokensMinted = 0;
    uint public MAX_TOKENS = 2751;

    string private _apiURI = "https://gateway.pinata.cloud/ipfs/QmQwEWoBYuLA17a6NBoNtCSH5uMVPKho7eJVfJAPGx6GNA/";

    mapping(address => bool) private _managers;
    address[] public level1holders;
    address[] public level2holders;
    address[] public level3holders;
    address[] public level4holders;
    address[] public level5holders;

    constructor() ERC721("WonderFinanceNFT", "WDFT") {
        _managers[msg.sender] = true;
    }

    function addManager(address _addr) external {
        require(_managers[msg.sender] == true, 'Error, you are not allowed');
        _managers[_addr] = true;
    }

    function fund() external payable {}

    function removeManager(address _addr) external {
        require(_managers[msg.sender] == true, 'Error, you are not allowed');
        _managers[_addr] = false;
    }

    function addLevel1Holder(address _addr) external {
        require(_managers[msg.sender] == true, 'Error, you are not allowed');
        level1holders.push(_addr);
    }

    function removeLevel1Holder(address _addr) external {
        require(_managers[msg.sender] == true, 'Error, you are not allowed');

        for (uint i = 0; i < level1holders.length; i ++) {
            if (level1holders[i] == _addr) {
                level1holders[i] = level1holders[level1holders.length - 1];
                level1holders.pop();
            }
        }
    }

    function addLevel2Holder(address _addr) external {
        require(_managers[msg.sender] == true, 'Error, you are not allowed');
        level2holders.push(_addr);
    }

    function removeLevel2Holder(address _addr) external {
        require(_managers[msg.sender] == true, 'Error, you are not allowed');

        for (uint i = 0; i < level2holders.length; i ++) {
            if (level2holders[i] == _addr) {
                level2holders[i] = level2holders[level2holders.length - 1];
                level2holders.pop();
            }
        }
    }

    function addLevel3Holder(address _addr) external {
        require(_managers[msg.sender] == true, 'Error, you are not allowed');
        level3holders.push(_addr);
    }

    function removeLevel3Holder(address _addr) external {
        require(_managers[msg.sender] == true, 'Error, you are not allowed');

        for (uint i = 0; i < level3holders.length; i ++) {
            if (level3holders[i] == _addr) {
                level3holders[i] = level3holders[level3holders.length - 1];
                level3holders.pop();
            }
        }
    }

    function addLevel4Holder(address _addr) external {
        require(_managers[msg.sender] == true, 'Error, you are not allowed');
        level4holders.push(_addr);
    }

    function removeLevel4Holder(address _addr) external {
        require(_managers[msg.sender] == true, 'Error, you are not allowed');

        for (uint i = 0; i < level4holders.length; i ++) {
            if (level4holders[i] == _addr) {
                level4holders[i] = level4holders[level4holders.length - 1];
                level4holders.pop();
            }
        }
    }

    function addLevel5Holder(address _addr) external {
        require(_managers[msg.sender] == true, 'Error, you are not allowed');
        level5holders.push(_addr);
    }

    function removeLevel5Holder(address _addr) external {
        require(_managers[msg.sender] == true, 'Error, you are not allowed');

        for (uint i = 0; i < level5holders.length; i ++) {
            if (level5holders[i] == _addr) {
                level5holders[i] = level5holders[level5holders.length - 1];
                level5holders.pop();
            }
        }
    }

    function distributeToLevel1(uint amount) external {
        require(_managers[msg.sender] == true, 'Error, you are not allowed');

        for (uint i = 0; i < level1holders.length; i ++) {
            payable(level1holders[i]).transfer(amount);
        } 
    }

    function distributeToLevel2(uint amount) external {
        require(_managers[msg.sender] == true, 'Error, you are not allowed');

        for (uint i = 0; i < level2holders.length; i ++) {
            payable(level2holders[i]).transfer(amount);
        } 
    }

    function distributeToLevel3(uint amount) external {
        require(_managers[msg.sender] == true, 'Error, you are not allowed');

        for (uint i = 0; i < level3holders.length; i ++) {
            payable(level3holders[i]).transfer(amount);
        } 
    }

    function distributeToLevel4(uint amount) external {
        require(_managers[msg.sender] == true, 'Error, you are not allowed');

        for (uint i = 0; i < level4holders.length; i ++) {
            payable(level4holders[i]).transfer(amount);
        } 
    }

    function distributeToLevel5(uint amount) external {
        require(_managers[msg.sender] == true, 'Error, you are not allowed');

        for (uint i = 0; i < level5holders.length; i ++) {
            payable(level5holders[i]).transfer(amount);
        } 
    }

    function mintNFT(address recipient, uint amount) 
        public returns(uint256) {
            require(tokensMinted + amount <= MAX_TOKENS, 'Error, all tokens are minted');
            for (uint16 i = 0; i < amount; i ++) {
                tokensMinted ++;
                _safeMint(recipient, tokensMinted);
            }
            return tokensMinted;
    }

    function _baseURI() internal view override returns (string memory) {
        return _apiURI;
    }

    function setBaseURI(string memory uri) external {
        require(_managers[msg.sender] == true, 'Error, you are not allowed');
        _apiURI = uri;
    }

    function withdrawFunds() external {
        require(_managers[msg.sender] == true, 'Error, you are not allowed');
        uint balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }
}