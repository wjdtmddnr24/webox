import { Point } from 'geojson';
import { Column, PrimaryColumn, Entity } from 'typeorm';

export const objects = [
  'police_car',
  'ambulance',
  'etc_car',
  'adult',
  'child',
  'bicycle',
  'motorcycle',
  'personal_mobility',
  'van',
  'bus',
  'sedan',
  'school_bus',
  'truck',
];

@Entity()
export class BlockMetadata {
  @PrimaryColumn('uuid', { unique: true })
  id: string;

  @Column()
  userId: string;

  @Column()
  recordId: string;

  @Column({
    nullable: true,
    type: 'geography',
    spatialFeatureType: 'Point',
    srid: 4326,
  })
  location: Point;

  @Column()
  createdAt: Date;

  @Column({ default: false })
  obj_police_car: boolean;

  @Column({ default: false })
  obj_ambulance: boolean;

  @Column({ default: false })
  obj_etc_car: boolean;

  @Column({ default: false })
  obj_adult: boolean;

  @Column({ default: false })
  obj_child: boolean;

  @Column({ default: false })
  obj_bicycle: boolean;

  @Column({ default: false })
  obj_motorcycle: boolean;

  @Column({ default: false })
  obj_personal_mobility: boolean;

  @Column({ default: false })
  obj_van: boolean;

  @Column({ default: false })
  obj_bus: boolean;

  @Column({ default: false })
  obj_sedan: boolean;

  @Column({ default: false })
  obj_school_bus: boolean;

  @Column({ default: false })
  obj_truck: boolean;
}
