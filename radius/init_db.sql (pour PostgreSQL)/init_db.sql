CREATE TABLE radcheck (
    id serial PRIMARY KEY,
    username varchar(64) NOT NULL,
    attribute varchar(64) NOT NULL,
    op char(2) NOT NULL DEFAULT '==',
    value varchar(253) NOT NULL
);

-- Utilisateur simple
INSERT INTO radcheck (username, attribute, op, value)
VALUES ('user1', 'Cleartext-Password', '==', 'pass1');

-- Utilisateur admin
INSERT INTO radcheck (username, attribute, op, value)
VALUES ('admin', 'Cleartext-Password', '==', 'admin123');

-- Utilisateur VPN
INSERT INTO radcheck (username, attribute, op, value)
VALUES ('vpnuser', 'Cleartext-Password', '==', 'vpnpass');

-- Utilisateur WiFi
INSERT INTO radcheck (username, attribute, op, value)
VALUES ('wifi', 'Cleartext-Password', '==', 'wifi1234');
