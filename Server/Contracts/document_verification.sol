// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DocumentVerificationSystem {
    
    // Define user types
    enum UserType { Issuer, Issuee }

    // Define document security types
    enum SecurityLevel { Public, Private }

    // Structure for storing user information
    struct User {
        string username;
        bytes32 userHash;
        UserType userType;
        string fullName;
        bytes32[] documents;  // Array to store document hashes owned by the user
    }

    // Structure for storing document information
    struct Document {
        bytes32 documentHash;
        string documentData; // Document data as a JSON string
        bytes32 ownerUserHash;
        SecurityLevel securityLevel;
        uint256 issueDate;
        address lastRequestedBy;
        uint256 lastRequestedAt;
    }

    // Mapping to store users and documents
    mapping(bytes32 => User) public users;           // Mapping from userHash to User struct
    mapping(bytes32 => Document) public documents;   // Mapping from documentHash to Document struct

    // Event emitted when a new user is created
    event UserCreated(bytes32 userHash, string username, UserType userType);

    // Event emitted when a new document is created
    event DocumentCreated(bytes32 documentHash, bytes32 ownerUserHash);

    // Function to create a new user
    function createUser(
        string memory _username,
        bytes32 _userHash,
        UserType _userType,
        string memory _fullName
    ) public {
        require(users[_userHash].userHash == 0, "User already exists");
        users[_userHash] = User({
            username: _username,
            userHash: _userHash,
            userType: _userType,
            fullName: _fullName,
            documents: new bytes32  // Initialize an empty array of documents
        });

        emit UserCreated(_userHash, _username, _userType);
    }

    // Function to fetch user details by user hash
    function getUser(bytes32 _userHash) public view returns (
        string memory username,
        UserType userType,
        string memory fullName,
        bytes32[] memory userDocuments
    ) {
        User storage user = users[_userHash];
        require(user.userHash != 0, "User does not exist");
        return (
            user.username,
            user.userType,
            user.fullName,
            user.documents
        );
    }

    // Function to create a new document
    function createDocument(
        bytes32 _documentHash,
        string memory _documentData,
        bytes32 _ownerUserHash,
        SecurityLevel _securityLevel
    ) public {
        require(users[_ownerUserHash].userHash != 0, "Owner user does not exist");
        require(documents[_documentHash].documentHash == 0, "Document already exists");

        documents[_documentHash] = Document({
            documentHash: _documentHash,
            documentData: _documentData,
            ownerUserHash: _ownerUserHash,
            securityLevel: _securityLevel,
            issueDate: block.timestamp,
            lastRequestedBy: address(0),
            lastRequestedAt: 0
        });

        // Add document hash to user's document list
        users[_ownerUserHash].documents.push(_documentHash);

        emit DocumentCreated(_documentHash, _ownerUserHash);
    }

    // Function to fetch document details by document hash
    function getDocument(bytes32 _documentHash) public view returns (
        string memory documentData,
        bytes32 ownerUserHash,
        SecurityLevel securityLevel,
        uint256 issueDate,
        address lastRequestedBy,
        uint256 lastRequestedAt
    ) {
        Document storage doc = documents[_documentHash];
        require(doc.documentHash != 0, "Document does not exist");

        return (
            doc.documentData,
            doc.ownerUserHash,
            doc.securityLevel,
            doc.issueDate,
            doc.lastRequestedBy,
            doc.lastRequestedAt
        );
    }

    // Function to request a document (logs the request timestamp and requester)
    function requestDocument(bytes32 _documentHash) public {
        Document storage doc = documents[_documentHash];
        require(doc.documentHash != 0, "Document does not exist");

        // Update last requested information
        doc.lastRequestedBy = msg.sender;
        doc.lastRequestedAt = block.timestamp;
    }
}
