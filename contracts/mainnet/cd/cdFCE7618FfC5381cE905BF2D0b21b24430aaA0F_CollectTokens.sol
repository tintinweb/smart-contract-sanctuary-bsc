// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20
{
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
}

contract CollectTokens
{
    ///签名公钥
    address public signPublicKey;
    mapping(bytes32=>uint256) public usedSignatures;

    address public adminAddress;
    
    event Draw(address account, address tokenAddress, uint256 amount, uint256 timestamp);

    event CollectMoney(address account, address tokenAddress, uint256 amount, string id, uint256 timestamp);

    constructor(address _signPublicKey) {
        signPublicKey = _signPublicKey;
        adminAddress = msg.sender;
    }
    modifier onlyAdmin() {
        require(msg.sender == adminAddress, "only admin");
        _;
    }
    function transferAdmin(address to) external onlyAdmin {
        adminAddress = to;
    }
    function setSignPublicKey(address signPublicKey_) external onlyAdmin {
        signPublicKey = signPublicKey_;
    }
    
    function collectTokens(address [] memory tokens) external onlyAdmin {
        for (uint256 i = 0; i < tokens.length; ++i) {
            if (IERC20(tokens[i]).balanceOf(address(this)) > 0) {
                IERC20(tokens[i]).transfer(adminAddress, IERC20(tokens[i]).balanceOf(address(this)));
            }
        }
    }

    function drawToken(address tokenAddress, uint256 amount, uint256 expiresAt, uint8 _v, bytes32 _r, bytes32 _s) external {
        require(IERC20(tokenAddress).balanceOf(address(this)) >= amount, "No enough tokens to draw");
        {
            bytes32 messageHash =  keccak256(
                abi.encodePacked(
                    signPublicKey,
                    tokenAddress,
                    amount,
                    expiresAt,
                    msg.sender,
                    "draw",
                    address(this)
                )
            );
            require(usedSignatures[messageHash] == 0, "operate has been executed");
            
            bytes32 prefixedHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));
            address addr = ecrecover(prefixedHash, _v, _r, _s);
            require(addr == signPublicKey, "signature error");
            
            usedSignatures[messageHash] = block.timestamp;
        }
        IERC20(tokenAddress).transfer(msg.sender, amount);
        emit Draw(msg.sender, tokenAddress, amount, block.timestamp);
    }

    function transferTokenIn(address token, uint256 amount, string memory id) external {
        require(IERC20(token).balanceOf(msg.sender) >= amount, "you have no enough amount");

        IERC20(token).transferFrom(msg.sender, address(this), amount);
        emit CollectMoney(msg.sender, token, amount, id, block.timestamp);
    }
}