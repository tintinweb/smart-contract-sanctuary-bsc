// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import "./Ownable.sol";

/**
 * @title SupplyChain
 * @dev Implements the transparency in the supply chain to 
 * understand the actual smart contracts
 */
contract SupplyChain is Ownable {
    enum ContractStatus {
        Created, // 0
        Official, // 1
        Closed // 2
    }

    enum ProductContractType {
        FreshLeaves, // 0
        DryLeaves, // 1
        LiquidLeaves, // 2
        Mitragynine, // 3
        SevenHydrioxy // 4
    }

    struct OnboardingContract {
        uint256 id_;
        uint256 farmerId;
        string documentURL;
        ContractStatus status;
        uint256 createdTime;
        uint256 officialTime;
        uint256 closedTime;
    }

    struct ProductContract {
        uint256 id_;
        uint256 initiatorId;
        uint256 partnerId;
        ProductContractType contractType;
        string documentURL;
        ContractStatus status;
        uint256 createdTime;
        uint256 officialTime;
        uint256 closedTime;
    }

    
    OnboardingContract[] internal onboardingContractList;
    mapping(uint256 => uint256) statusToOnboardingContractCounts;
    ProductContract[] productContractList;
    mapping(uint256 => uint256) typeToProductContractCounts;
    mapping(uint256 => mapping(uint256 => uint256)) typeToStatusProductContractCounts;

    // Events
    event OnboardingContractCreated(
        uint256 id, 
        uint256 farmerId, 
        string documentURL, 
        uint256 createdTime
    );
    event OnboardingContractOfficial(
        uint256 id, 
        string documentURL, 
        uint256 officialTime
    );
    event OnboardingContractClosed(
        uint256 id, 
        uint256 closedTime
    );
    event ProductContractCreated(
        uint256 id, 
        uint256 initiatorId, 
        uint256 partnerId, 
        uint256 contractType, 
        string documentURL, 
        uint256 createdTime
    );
    event ProductContractOfficial(
        uint256 id, 
        uint256 contractType, 
        string documentURL, 
        uint256 officialTime
    );
    event ProductContractClosed(
        uint256 id, 
        uint256 contractType,
        uint256 closedTime
    );

    function initialize() public override initializer {
        Ownable.initialize();
    }

    // External Functions
    /**
     * @dev To generate an on-boarding contract
     * @param farmerId farmer id that the company will contract with
     * @param documentURL the url that the contract's digital document was stored on
     */
    function generateOnboardingContract(
        uint256 farmerId, 
        string memory documentURL
    )
        external 
        onlyOwner 
    {
        uint256 newContractId = onboardingContractList.length;
        OnboardingContract memory onboardingContract = OnboardingContract({
            id_: newContractId,
            farmerId: farmerId,
            documentURL: documentURL,
            status: ContractStatus.Created,
            createdTime: block.timestamp,
            officialTime: 0,
            closedTime: 0
        });

        onboardingContractList.push(onboardingContract);
        statusToOnboardingContractCounts[uint256(ContractStatus.Created)]++;

        emit OnboardingContractCreated(newContractId, farmerId, documentURL, block.timestamp);
    }

    /**
     * @dev To update the contract status as official
     * @param contractId contract id to sign
     * @param documentURL the url that the signed contract's digital document was stored on
     */
    function signOnboardingContract(uint256 contractId, string memory documentURL) external onlyOwner {
        require(onboardingContractList[contractId].id_ == contractId, "The contract id not exists");
        require(onboardingContractList[contractId].status == ContractStatus.Created, 
            "The contract should be just created");

        onboardingContractList[contractId].documentURL = documentURL;
        onboardingContractList[contractId].status = ContractStatus.Official;
        onboardingContractList[contractId].officialTime = block.timestamp;
        statusToOnboardingContractCounts[uint256(ContractStatus.Created)]--;
        statusToOnboardingContractCounts[uint256(ContractStatus.Official)]++;

        emit OnboardingContractOfficial(contractId, documentURL, block.timestamp);
    }

    /**
     * @dev To update the contract status as closed
     * @param contractId contract id to close
     */
    function closeOnboardingContract(uint256 contractId) external onlyOwner {
        require(onboardingContractList[contractId].id_ == contractId, "The contract id not exists");
        require(onboardingContractList[contractId].status == ContractStatus.Official, 
            "The contract should be just signed");

        onboardingContractList[contractId].status = ContractStatus.Closed;
        onboardingContractList[contractId].closedTime = block.timestamp;
        statusToOnboardingContractCounts[uint256(ContractStatus.Official)]--;
        statusToOnboardingContractCounts[uint256(ContractStatus.Closed)]++;

        emit OnboardingContractClosed(contractId, block.timestamp);
    }

    /**
     * @dev To get onboarding contract list
     * @return contractList the list of the onboarding contracts
     */
    function getOnboardingContractList() 
        external 
        view 
        onlyOwner
        returns (OnboardingContract[] memory) 
    {
        return onboardingContractList;
    }

    /**
     * @dev To get the specified onboarding contract
     * @param id the id of the contract to get
     * @return contract the onboarding contract
     */
    function getOnboardingContract(uint256 id) 
        external 
        view 
        onlyOwner
        returns (OnboardingContract memory) 
    {
        require(onboardingContractList[id].id_ == id, 'Incorrect contract id');
        return onboardingContractList[id];
    }

    /**
     * @dev To get the count of onboarding contracts with the status
     * @param status the status that the returning contracts will have
     * @return uint256 the count of onboarding contracts with the status
     */
    function getOnboardingContractCountWithStatus(uint256 status) 
        external 
        view 
        onlyOwner
        returns (uint256) 
    {
        return statusToOnboardingContractCounts[status];
    }

    /**
     * @dev To get the count of onboarding contracts
     * @return uint256 the count of onboarding contracts
     */
    function getOnboardingContractCount() 
        external 
        view 
        onlyOwner
        returns (uint256) 
    {
        return onboardingContractList.length;
    }

    /**
     * @dev To get onboarding contract list with the specific status
     * @param status the desired status of the list
     * @return contractList the list of the onboarding contracts
     */
    function getOnboardingContractListWithStatus(uint256 status) 
        external 
        view 
        onlyOwner
        returns (OnboardingContract[] memory) 
    {
        uint256 contractCount = onboardingContractList.length;
        uint256 targetCount = statusToOnboardingContractCounts[status];
        OnboardingContract[] memory resultList = new OnboardingContract[](targetCount);
        uint256 counter = 0;
        for (uint256 i = 0; i < contractCount; i++) {
            OnboardingContract memory contract_ = onboardingContractList[i];
            if (uint256(contract_.status) == status) {
                resultList[counter] = contract_;
                counter++;
            }
        }
        return resultList;
    }

    /**
     * @dev To get onboarding contract list without the specific status
     * @param status the unwanted status of the list
     * @return contractList the list of the onboarding contracts
     */
    function getOnboardingContractListWithoutStatus(uint256 status) 
        external 
        view 
        onlyOwner
        returns (OnboardingContract[] memory) 
    {
        uint256 contractCount = onboardingContractList.length;
        uint256 targetCount = contractCount - statusToOnboardingContractCounts[status];
        OnboardingContract[] memory resultList = new OnboardingContract[](targetCount);
        uint256 counter = 0;
        for (uint256 i = 0; i < contractCount; i++) {
            OnboardingContract memory contract_ = onboardingContractList[i];
            if (uint256(contract_.status) != status) {
                resultList[counter] = contract_;
                counter++;
            }
        }
        return resultList;
    }

    /**
     * @dev To generate a product contract
     * @param initiatorId user id who generates the contract(ex. for fresh leaves contract it is GACP id)
     * @param partnerId user id who sign with
     * @param contractType product contract type(ex. fresh leaves, dry leaves, ...)
     * @param documentURL the url that the contract's digital document was stored on
     */
    function generateProductContract(
        uint256 initiatorId, 
        uint256 partnerId,
        uint256 contractType,
        string memory documentURL
    ) 
        external 
        onlyOwner 
    {
        uint256 newContractId = productContractList.length;
        ProductContract memory productContract = ProductContract({
            id_: newContractId,
            initiatorId: initiatorId,
            partnerId: partnerId,
            contractType: ProductContractType(contractType),
            documentURL: documentURL,
            status: ContractStatus.Created,
            createdTime: block.timestamp,
            officialTime: 0,
            closedTime: 0
        });

        productContractList.push(productContract);

        typeToProductContractCounts[contractType]++;
        typeToStatusProductContractCounts[contractType][uint256(ContractStatus.Created)]++;

        emit ProductContractCreated(
            newContractId, 
            initiatorId, 
            partnerId, 
            contractType,
            documentURL, 
            block.timestamp
        );
    }

    /**
     * @dev To update the product contract status as official
     * @param contractId contract id to sign
     * @param documentURL the url that the signed contract's digital document was stored on
     */
    function signProductContract(uint256 contractId, string memory documentURL) external onlyOwner {
        require(productContractList[contractId].id_ == contractId, "The contract id not exists");
        require(productContractList[contractId].status == ContractStatus.Created, 
            "The contract should be just created");

        productContractList[contractId].documentURL = documentURL;
        productContractList[contractId].status = ContractStatus.Official;
        productContractList[contractId].officialTime = block.timestamp;

        ProductContractType contractType = productContractList[contractId].contractType;

        typeToStatusProductContractCounts[uint256(contractType)][uint256(ContractStatus.Created)]--;
        typeToStatusProductContractCounts[uint256(contractType)][uint256(ContractStatus.Official)]++;

        emit ProductContractOfficial(
            contractId, 
            uint256(contractType), 
            documentURL, 
            block.timestamp
        );
    }

    /**
     * @dev To close the product contract
     * @param contractId contract id to close
     */
    function closeProductContract(uint256 contractId) external onlyOwner {
        require(productContractList[contractId].id_ == contractId, "The contract id not exists");
        require(productContractList[contractId].status == ContractStatus.Official, 
            "The contract should be just signed");

        productContractList[contractId].status = ContractStatus.Closed;
        productContractList[contractId].closedTime = block.timestamp;

        ProductContractType contractType = productContractList[contractId].contractType;
        typeToStatusProductContractCounts[uint256(contractType)][uint256(ContractStatus.Official)]--;
        typeToStatusProductContractCounts[uint256(contractType)][uint256(ContractStatus.Closed)]++;

        emit ProductContractClosed(
            contractId, 
            uint256(contractType), 
            block.timestamp
        );
    }

    /**
     * @dev To get product contract list
     * @return contractList the list of the product contracts
     */
    function getProductContractList() 
        external 
        view 
        onlyOwner
        returns (ProductContract[] memory) 
    {
        return productContractList;
    }

    /**
     * @dev To get the specified product contract
     * @param id the id of the contract to get
     * @return contract the onboarding contract
     */
    function getProductContract(uint256 id) 
        external 
        view 
        onlyOwner
        returns (ProductContract memory) 
    {
        require(productContractList[id].id_ == id, 'Incorrect contract id');
        return productContractList[id];
    }

    /**
     * @dev To get the count of product contracts with the contract type
     * @param contractType the desired contract type
     * @return uint256 the count of product contracts with the contract type
     */
    function getProductContractCountWithType(uint256 contractType) 
        external 
        view 
        onlyOwner
        returns (uint256) 
    {
        return typeToProductContractCounts[contractType];
    }

    /**
     * @dev To get the count of product contracts with the contract type and status
     * @param contractType the desired contract type
     * @param status the desired contract status
     * @return uint256 the count of onboarding contracts with the contract type and status
     */
    function getProductContractCountWithTypeStatus(uint256 contractType, uint256 status) 
        external 
        view 
        onlyOwner
        returns (uint256) 
    {
        return typeToStatusProductContractCounts[contractType][status];
    }

    /**
     * @dev To get the count of product contracts
     * @return uint256 the count of product contracts
     */
    function getProductContractCount() 
        external 
        view 
        onlyOwner
        returns (uint256) 
    {
        return productContractList.length;
    }

    /**
     * @dev To get product contract list with the specific type
     * @param productType the desired product type
     * @return contractList the list of the product contracts with the product type
     */
    function getProductContractListWithType(uint256 productType) 
        external 
        view 
        onlyOwner
        returns (ProductContract[] memory) 
    {
        uint256 contractCount = productContractList.length;
        uint256 targetCount = typeToProductContractCounts[productType];
        ProductContract[] memory resultList = new ProductContract[](targetCount);
        uint256 counter = 0;
        for (uint256 i = 0; i < contractCount; i++) {
            ProductContract memory contract_ = productContractList[i];
            if (uint256(contract_.contractType) == productType) {
                resultList[counter] = contract_;
                counter++;
            }
        }
        return resultList;
    }

    /**
     * @dev To get product contract list with the specific type and status
     * @param productType the desired product type
     * @param status the desired contract status
     * @return contractList the list of the product contracts with the product type and status
     */
    function getProductContractListWithTypeStatus(uint256 productType, uint256 status) 
        external 
        view 
        onlyOwner
        returns (ProductContract[] memory) 
    {
        uint256 contractCount = productContractList.length;
        uint256 targetCount = typeToStatusProductContractCounts[productType][status];
        ProductContract[] memory resultList = new ProductContract[](targetCount);
        uint256 counter = 0;
        for (uint256 i = 0; i < contractCount; i++) {
            ProductContract memory contract_ = productContractList[i];
            if (uint256(contract_.contractType) == productType && uint256(contract_.status) == status) {
                resultList[counter] = contract_;
                counter++;
            }
        }
        return resultList;
    }
}