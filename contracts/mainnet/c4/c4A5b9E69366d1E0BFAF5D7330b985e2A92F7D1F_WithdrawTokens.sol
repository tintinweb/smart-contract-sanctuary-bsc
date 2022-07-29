/**
 *Submitted for verification at BscScan.com on 2022-07-29
*/

// Sources flattened with hardhat v2.9.1 https://hardhat.org

// File contracts/WithdrawTokens.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20
{
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
}
interface PLCToken {
    function withdrawMint(address account, uint256 amount) external;
}

contract WithdrawTokens
{
    ///签名公钥
    address public signPublicKey;
    mapping(bytes32=>uint256) public usedSignatures;

    address public adminAddress;
    
    address public feeReceiver;
    address public feeTokenAddress;
    uint256 public fee;

    // token addrs
    address public plcToken;
    
    event Withdraw(address account, address tokenAddress, uint256 amount, string id, uint256 timestamp);
    event WithdrawPLC(address account, address tokenAddress, uint256 totalAmount, uint256 mintAmount, uint256 descAmount, string id, uint256 timestamp);

    constructor(address _signPublicKey, address _feeReceiver, address _feeTokenAddress, uint256 _fee, address _plcToken) {
        signPublicKey = _signPublicKey;
        adminAddress = msg.sender;
        
        feeReceiver = _feeReceiver;
        feeTokenAddress = _feeTokenAddress;
        fee = _fee;

        plcToken = _plcToken;
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
    function setFeeToken(address _feeTokenAddress, uint256 _fee) external onlyAdmin {
        feeTokenAddress = _feeTokenAddress;
        fee = _fee;
    }
    function transferFeeReceiver(address _feeReceiver) external onlyAdmin {
        feeReceiver = _feeReceiver;
    }
    function setPLCToken(address _plcToken) external onlyAdmin {
        plcToken = _plcToken;
    }

    function withdrawToken(address tokenAddress, uint256 amount, string memory id, uint256 expiresAt, uint8 _v, bytes32 _r, bytes32 _s) external {
        require(expiresAt > block.timestamp, "time expired");
        require(IERC20(feeTokenAddress).balanceOf(msg.sender) >= fee, "no enough fee to withdraw");
        require(IERC20(tokenAddress).balanceOf(address(this)) >= amount, "no enough token in contract");

        {
            bytes32 messageHash =  keccak256(
                abi.encodePacked(
                    signPublicKey,
                    amount,
                    expiresAt,
                    id,
                    msg.sender,
                    tokenAddress,
                    "withdraw",
                    address(this)
                )
            );
            require(usedSignatures[messageHash] == 0, "withdraw has been executed");
            
            bytes32 prefixedHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));
            address addr = ecrecover(prefixedHash, _v, _r, _s);
            require(addr == signPublicKey, "signature error");
            
            usedSignatures[messageHash] = block.timestamp;
        }

        IERC20(feeTokenAddress).transferFrom(msg.sender, feeReceiver, fee);
        IERC20(tokenAddress).transfer(msg.sender, amount);
        emit Withdraw(msg.sender, tokenAddress, amount, id, block.timestamp);
    }

    function withdrawPLC(uint256 totalAmount, uint256 mintAmount, uint256 descAmount, string memory id, uint256 expiresAt, uint8 _v, bytes32 _r, bytes32 _s) external {
        require(expiresAt > block.timestamp, "time expired");
        require(IERC20(feeTokenAddress).balanceOf(msg.sender) >= fee, "no enough fee to withdraw");

        {
            bytes32 messageHash =  keccak256(
                abi.encodePacked(
                    signPublicKey,
                    totalAmount,
                    mintAmount,
                    descAmount,
                    expiresAt,
                    id,
                    msg.sender,
                    plcToken,
                    "withdraw",
                    address(this)
                )
            );
            require(usedSignatures[messageHash] == 0, "withdraw has been executed");
            
            bytes32 prefixedHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));
            address addr = ecrecover(prefixedHash, _v, _r, _s);
            require(addr == signPublicKey, "signature error");
            
            usedSignatures[messageHash] = block.timestamp;
        }

        IERC20(feeTokenAddress).transferFrom(msg.sender, feeReceiver, fee);
        PLCToken(plcToken).withdrawMint(msg.sender, mintAmount);
        PLCToken(plcToken).withdrawMint(plcToken, descAmount);
        
        emit WithdrawPLC(msg.sender, plcToken, totalAmount, mintAmount, descAmount, id, block.timestamp);
    }
    
    function adminCollectTokens(address [] memory tokens) external onlyAdmin {
        for (uint256 i = 0; i < tokens.length; ++i) {
            if (IERC20(tokens[i]).balanceOf(address(this)) > 0) {
                IERC20(tokens[i]).transfer(adminAddress, IERC20(tokens[i]).balanceOf(address(this)));
            }
        }
    }
}