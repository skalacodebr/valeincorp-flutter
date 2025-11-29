-- Tabela para tipos de medidas de unidades (configurável)
CREATE TABLE `tipos_medida_unidades` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `nome` varchar(255) NOT NULL COMMENT 'Nome do tipo de medida (ex: Área Total, Área Útil, etc.)',
  `unidade` varchar(50) NOT NULL DEFAULT 'm²' COMMENT 'Unidade de medida (m², m, etc.)',
  `ativo` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Se o tipo está ativo',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `tipos_medida_unidades_nome_unique` (`nome`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tipos de medidas configuráveis para unidades';

-- Inserir tipos padrão
INSERT INTO `tipos_medida_unidades` (`nome`, `unidade`, `ativo`, `created_at`, `updated_at`) VALUES
('Área Total', 'm²', 1, NOW(), NOW()),
('Área com Box', 'm²', 1, NOW(), NOW()),
('Área Útil', 'm²', 1, NOW(), NOW());

-- Tabela para armazenar as medidas das unidades
CREATE TABLE `medidas_unidades` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `unidade_id` bigint(20) unsigned NOT NULL COMMENT 'ID da unidade',
  `tipo_medida_id` bigint(20) unsigned NOT NULL COMMENT 'ID do tipo de medida',
  `valor` decimal(10,2) NOT NULL COMMENT 'Valor da medida',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `medidas_unidades_unidade_tipo_unique` (`unidade_id`, `tipo_medida_id`),
  KEY `medidas_unidades_unidade_id_index` (`unidade_id`),
  KEY `medidas_unidades_tipo_medida_id_index` (`tipo_medida_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Medidas das unidades por tipo configurável';
